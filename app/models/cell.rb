# app/models/cell.rb

class Cell < ApplicationRecord
  belongs_to :section, foreign_key: :section_name, primary_key: :section_name, optional: true

  after_find :verify_checksum, unless: -> { Thread.current[:skip_checksum_verification] }

  include Checksum
  include Validation

  validate :content_is_valid
  validates :cell_name, :section_name, presence: true

  scope :by_section_name, ->(name) { where(section_name: name).order(:cell_order) }

  def self.ransackable_attributes(auth_object = nil)
    %w[cell_name section_name image link content]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  private

  def verify_checksum
    return unless content.present?

    expected_checksum = generate_checksum(content)

    unless checksum == expected_checksum
      Rails.logger.error "Checksum mismatch for record ##{id}"

      self.errors = [] unless self.errors.present?

      raise ActiveRecord::RecordInvalid, "Checksum verification failed for Section record ##{id}"
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
