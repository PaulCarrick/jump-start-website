# app/models/cell.rb
class Cell < ApplicationRecord
  belongs_to :section

  after_find :verify_checksum, unless: -> { Thread.current[:skip_checksum_verification] }

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

  def self.generate_unique_name(prefix = "new-column_")
    existing_names = Cell.where("cell_name ~ ?", "^#{prefix}\\d+$").pluck(:cell_name)

    max_number = existing_names
                   .map { |name| name[/\d+\z/].to_i }
                   .max || 0

    "#{prefix}#{max_number + 1}"
  end

  private

  def populate_section_id_from_name
    return if section_id.present?

    section = Section.find_by(section_name: section_name) if section_name.present?

    if section
      self.section_id = section.id
    else
      self.errors ||= []
      error       = "No section ID is present and cannot find session by name."

      errors.add(:section_id, error)
      Rails.logger.error error
      raise ActiveRecord::RecordInvalid, error
    end
  end

  def verify_checksum
    return unless content.present?

    expected_checksum = generate_checksum(content)

    unless checksum == expected_checksum
      self.errors ||= []
      error       = "Checksum mismatch for Cell ##{id}"

      errors.add(:content, error)
      Rails.logger.error error
      raise ActiveRecord::RecordInvalid, error
    end
  end

  def content_is_valid
    return unless content.present?

    skip_check = content =~ /^\s*<title>/

    unless skip_check || validate_html(content, :content)
      self.errors ||= []
      error       = "Invalid HTML in Content."

      errors.add(:content, error)
      Rails.logger.error error
      raise ActiveRecord::RecordInvalid, error
    end
  end
end
