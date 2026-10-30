class ImageFile < ApplicationRecord
  include Enableable
  include BitemporalRecord
  after_save :retain_temporal_upload
  after_find :verify_checksum, unless: -> { Thread.current[:skip_checksum_verification] }

  include Rails.application.routes.url_helpers
  include Checksum
  include Validation

  has_one_attached :image
  reflect_on_association(:image_attachment).tap do |reflection|
    reflection.options[:primary_key] = :id
    reflection.options[:foreign_key] = 'record_id'
    %i[@foreign_key @active_record_primary_key].each { |cache| reflection.remove_instance_variable(cache) if reflection.instance_variable_defined?(cache) }
  end


  # Keep draft uploads separate from the stable live Active Storage attachment.
  def image=(value)
    return super unless PublishingContext.editing && !PublishingContext.deploying
    return if value.blank?
    blob = if value.respond_to?(:tempfile)
      ActiveStorage::Blob.create_and_upload!(io: value.tempfile, filename: value.original_filename, content_type: value.content_type)
    elsif value.is_a?(Hash)
      ActiveStorage::Blob.create_and_upload!(**value)
    elsif value.is_a?(ActiveStorage::Blob)
      value
    else
      ActiveStorage::Blob.find_signed!(value)
    end
    self.attachment_blob_id = blob.id
  end

  def image
    return DraftImageAttachment.new(self) if has_attribute?(:attachment_blob_id) && attachment_blob_id.present?
    super
  end

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
    rails_blob_path(image.respond_to?(:blob) ? image.blob : image, only_path: true) if image.attached?
  end

  def as_json(options = {})
    super(options).merge({ image_url: image_url })
  end

  private

  def retain_temporal_upload
    return unless has_attribute?(:attachment_blob_id) && attachment_blob_id.present?
    ActiveStorage::Attachment.find_or_create_by!(record: self, name: "temporal_upload_#{version}", blob_id: attachment_blob_id)
  end

  def verify_checksum
    verify_checksum_for([ description, caption ].compact.join)
  end

  def description_is_valid
    return unless description.present?

    unless validate_html(description, :description)
      errors.add(:base, "Invalid HTML in Description.")
    end
  end
end
