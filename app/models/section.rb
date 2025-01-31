# app/models/section.rb

class Section < ApplicationRecord
  after_find :verify_checksum, unless: -> { Thread.current[:skip_checksum_verification] }
  after_find :setup_formatting

  include Checksum
  include Validation

  validate :at_least_one_field_present
  validate :description_is_valid

  scope :by_content_type, ->(type) { where(content_type: type).order(:section_order) }

  def self.ransackable_attributes(auth_object = nil)
    %w[content_type section_name image link description]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  private

  def update_attribute(attributes, key, regex, classes)
    attributes[key] = Regexp.last_match(1) if classes =~ regex && !attributes[key].present?
  end

  def setup_formatting
    return unless self.formatting.present?

    row_style      = self.formatting['row_style']
    self.row_style = row_style.gsub(/\A"|"\z/, '') if row_style.present? && !self.row_style.present?

    # Update text attributes
    update_attribute(self.text_attributes, "text_margin_top", /(mt-\d)/, formatting["text_classes"])
    update_attribute(self.text_attributes, "text_margin_left", /(ms-\d)/, formatting["text_classes"])
    update_attribute(self.text_attributes, "text_margin_bottom", /(mb-\d)/, formatting["text_classes"])
    update_attribute(self.text_attributes, "text_margin_right", /(me-\d)/, formatting["text_classes"])

    # Update image attributes
    update_attribute(self.image_attributes, "image_margin_top", /(mt-\d)/, formatting["image_classes"])
    update_attribute(self.image_attributes, "image_margin_left", /(ms-\d)/, formatting["image_classes"])
    update_attribute(self.image_attributes, "image_margin_bottom", /(mb-\d)/, formatting["image_classes"])
    update_attribute(self.image_attributes, "image_margin_right", /(me-\d)/, formatting["image_classes"])

    return if self.div_ratio.present?
    return unless (self.row_style == "text-left") || (self.row_style == "text-right")

    text_classes  = self.formatting['text_classes']
    image_classes = self.formatting['image_classes']
    text_width    = Regexp.last_match(1).to_i if text_classes.present? && text_classes =~ /col\-(\d{1,2})/
    image_width   = Regexp.last_match(1).to_i if image_classes.present? && image_classes =~ /col\-(\d{1,2})/

    return if text_width.present? || image_width.present?

    original_text_percentage  = ((text_width.to_f / 12.0) * 100).floor if text_width.present?
    original_image_percentage = 100 - original_text_percentage if original_text_percentage.present?
    original_ratio            = "#{original_text_percentage}:#{original_image_percentage}"
    text_percentage           = ((text_width.to_f / 12.0) * 100).floor
    image_percentage          = ((image_width.to_f / 12.0) * 100).floor

    ratios = {
      90 => "90:10",
      80 => "80:20",
      70 => "70:30",
      60 => "60:40",
      50 => "50:50",
      40 => "40:60",
      30 => "30:70",
      20 => "20:80",
      10 => "10:90"
    }

    closest_text_ratio  = ratios.keys.min_by { |key| (text_percentage - key).abs }
    closest_image_ratio = ratios.keys.min_by { |key| (image_percentage - key).abs }
    div_ratio           = ratios[closest_text_ratio] if (closest_text_ratio + closest_image_ratio) === 100
    self.div_ratio      = div_ratio unless div_ratio != original_ratio
  end

  def verify_checksum
    return unless description.present?

    expected_checksum = generate_checksum(description)

    unless checksum == expected_checksum
      Rails.logger.error "Checksum mismatch for record ##{id}"

      self.errors = [] unless self.errors.present?

      raise ActiveRecord::RecordInvalid, "Checksum verification failed for Section record ##{id}"
    end
  end

  def at_least_one_field_present
    return unless image.blank? && link.blank? && description.blank?

    errors.add(:base, "At least one of image, link, or description must be present.")
  end

  def description_is_valid
    return unless description.present?

    skip_check = description =~ /^\s*<title>/

    unless skip_check || validate_html(description, :description)
      errors.add(:base, "Invalid HTML in Description.")
    end
  end
end
