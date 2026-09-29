# app/models/cell.rb
class Cell < ApplicationRecord
  belongs_to :section, inverse_of: :cells

  after_find :verify_checksum, unless: -> { Thread.current[:skip_checksum_verification] }
  before_validation :populate_section_id_from_name

  include Checksum
  include Validation

  validates :cell_name, presence: true, uniqueness: true
  validate :content_is_valid

  scope :by_section_name, ->(name) { where(section_name: name).order(:cell_order) }

  def self.ransackable_attributes(auth_object = nil)
    %w[cell_name section_name image link content]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  # See Section#generate_unique_name for why this is based on the table's
  # own max id rather than counting currently-matching "new-column_N" names -
  # the same reissue-after-rename risk applies here.
  def self.generate_unique_name(prefix = "new-column_")
    "#{prefix}#{(Cell.maximum(:id) || 0) + 1}"
  end

  private

  def populate_section_id_from_name
    # section_id is blank for a brand-new Cell whose Section is also brand new
    # (e.g. creating a new Page with a new Section and its cells in one nested
    # save) - inverse_of above means the built Cell already has the in-memory
    # Section object at this point via the association, even though neither
    # has been saved yet and section_id isn't set. Only fall back to looking
    # the section up by name when neither is present.
    return if section_id.present? || section.present?

    section = Section.find_by(section_name: section_name) if section_name.present?

    if section
      self.section_id = section.id
    else
      error = "No section ID is present and cannot find a section by name."

      errors.add(:section_id, error)
      Rails.logger.error error
    end
  end

  def verify_checksum
    return unless content.present?

    expected_checksum = generate_checksum(content)

    unless checksum == expected_checksum
      # Log rather than raise: an after_find hook is not the place to hard-fail
      # on legacy/out-of-band data, since that breaks every read of the row.
      Rails.logger.error "Checksum mismatch for Cell ##{id}"
    end
  end

  def content_is_valid
    return unless content.present?

    skip_check = content =~ /^\s*<title>/

    unless skip_check || validate_html(content, :content)
      errors.add(:base, "Invalid HTML in Content.")
    end
  end
end
