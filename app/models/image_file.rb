class ImageFile < ApplicationRecord
  after_find :verify_checksum, unless: -> { Thread.current[:skip_checksum_verification] }

  include Rails.application.routes.url_helpers
  include Checksum
  include Validation

  has_one_attached :image

  validates :name, :image, presence: true
  validate :description_is_valid

  scope :jpegs_with_captions_in_an_image_group, ->() { where.not(group: nil).where.not(caption: nil).where(mime_type: 'image/jpeg') }
  scope :by_image_group, ->(group) { where(group: group).order(:slide_order) }
  scope :by_name, ->(name) { where(name: name) }
  scope :images, ->() { where.not(mime_type: "video/mp4").distinct.order(:name).pluck(:name) }
  scope :groups, ->() { all.distinct.order(:group).pluck(:group) }
  scope :videos, ->() { where(mime_type: "video/mp4").distinct.order(:name).pluck(:name) }

  def self.ransackable_attributes(auth_object = nil)
    %w[ name group caption description ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[ image_attachment image_blob ]
  end

  def image_url
    Rails.application.routes.url_helpers.url_for(self.image) if self.image.attached?
  end

  def as_json(options = {})
    super(options).merge({ image_url: image_url })
  end

  private

  def verify_checksum
    return unless description.present? || caption.present?

    value = description

    if caption.present?
      if value.present?
        value += caption
      else
        value = caption
      end
    end

    expected_checksum = generate_checksum(value)

    unless checksum == expected_checksum
      Rails.logger.error "Checksum mismatch for record ##{id}"
      raise ActiveRecord::RecordInvalid, "Checksum verification failed for Image File record ##{id}"
    end
  end

  def description_is_valid
    return unless description.present?

    unless validate_html(description, :description)
      errors.add(:base, "Invalid HTML in Description.")
    end
  end
end
