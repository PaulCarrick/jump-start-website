# app/models/section.rb

class Section < ApplicationRecord
  has_many :columns, foreign_key: "section_name", primary_key: "section_name", dependent: :destroy

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

  def generate_columns
    begin
      row_style    = formatting["row_style"] if formatting
      section_name = content_type unless section_name.present?

      if image&.start_with?("ImageSection:") # Special case
        image_section             = image[13..-1]
        text_column, image_column = generate_columns_from_image_section(image_section)

        text_column.save!
        image_column.save!
      else
        if row_style.present?
          case row_style

          when 'text-single'
            column = generate_column_from_text_single

            column.save! if column.present?

          when 'text-left'
            text_column, image_column = generate_columns_from_text_left

            text_column.save!
            image_column.save!

          when 'image-left'
            text_column, image_column = generate_columns_from_image_left

            image_column.save!
            text_column.save!

          when 'text-right'
            text_column, image_column = generate_columns_from_text_right

            image_column.save!
            text_column.save!

          when 'image-right'
            text_column, image_column = generate_columns_from_image_right

            text_column.save!
            image_column.save!

          when 'text-top'
            text_column, image_column = generate_columns_from_text_top

            text_column.save!
            image_column.save!

          when 'text-bottom'
            text_column, image_column = generate_columns_from_text_bottom

            image_column.save!
            text_column.save!
          else
            column = generate_column_from_text_single

            column.save! if column.present?
          end
        else
          column = generate_column_from_text_single

          column.save! if column.present?
        end
      end
    rescue => e
      errors.add(:base, "Cannot generate columns from: #{section_name}..Error: #{e.message}")

      raise ActiveRecord::Rollback
    end
  end

  private

  def get_percentages(text_classes, image_classes)
    results = [ nil, nil ]

    return results unless text_classes.present? || image_classes.present?

    text_width  = Regexp.last_match(2).to_i if text_classes.present? &&
      text_classes =~ /col(?:-(xs|sm|md|lg|xl|xxl))?-(\d{1,2})/

    image_width = Regexp.last_match(2).to_i if image_classes.present? &&
      image_classes =~ /col(?:-(xs|sm|md|lg|xl|xxl))?-(\d{1,2})/

    if text_width.present? && image_width.present?
      text_percentage  = ((text_width.to_f / 12.0) * 100).floor if text_width.present?
      image_percentage = 100 - text_percentage if text_percentage.present?
      text_width       = "#{text_percentage}%"
      image_width      = "#{image_percentage}%"
    elsif text_classes.present?
      text_width  = "100%"
      image_width = "0%"
    else
      text_width  = "0%"
      image_width = "100%"
    end

    [ text_width, image_width ]
  end

  def configure_formatting(formatting, column, column_type = "text")
    return unless formatting.present?

    column.formatting = formatting
    classes           = nil
    styles            = nil

    column.formatting.delete("row_style") # Not used
    column.formatting.delete("div_ratio") # Not used

    column.formatting.each do |key, value|
      if column_type == "image"
        if key == "image_classes"
          classes = value
        elsif key == "image_styles"
          styles = value
        end
      else
        if key == "text_classes"
          classes = value
        elsif key == "text_styles"
          styles = value
        end
      end
    end

    column.formatting["classes"] = classes unless classes.nil?
    column.formatting["styles"]  = styles unless styles.nil?

    column.formatting.delete("text_styles") # Not used
    column.formatting.delete("text_classes") # Not used
    column.formatting.delete("image_styles") # Not used
    column.formatting.delete("image_classes") # Not used

    if column.formatting["expanding_rows"].present?
      if image&.start_with?("ImageSection:")
        column.formatting.delete("expanding_rows") if column_type == "text"
      else
        column.formatting.delete("expanding_rows") if column_type == "image"
      end
    end
  end

  def generate_column(section_name, column_name, description, image, link,
                      column_order = 1, width = "100%", column_type = "text")
    column              = Column.new
    column.section_name = section_name
    column.column_name  = column_name
    column.column_type  = column_type
    column.column_order = column_order
    column.content      = description if column_type == "text" || self.image&.start_with?("ImageSection:")
    column.image        = image if column_type == "image"
    column.link         = link if column_type == "image"
    column.width        = width

    configure_formatting(formatting, column, column_type) if formatting.present?

    column
  end

  def generate_column_from_section(column_name,
                                   column_order = 1,
                                   width = "100%",
                                   column_type = "text")
    generate_column(section_name, column_name, description, image, link,
                    column_order, width, column_type)
  end

  def generate_columns_from_image_section(file_name)
    image_file = ImageFile.find_by(name: file_name)

    if image_file.present?
      caption    = image_file.caption.to_s
      image_link = image_file.image_url.to_s

      # Check if caption contains only <p> tags or no HTML
      if caption.match?(/\A(\s*<p>.*?<\/p>\s*)*\z/i)
        content = sanitize_html("<div class='display-4 fw-bold mb-1 text-dark'>#{caption}</div>")
      else
        content = caption
      end

      additional_text = image_file.description.to_s
    else
      additional_text = ""
      image_link      = nil
      content         = description
      file_name       = "missing-image"
    end

    text_width, image_width = get_percentages(formatting["text_classes"],
                                              formatting["image_classes"])
    image_tag               = "ImageFile:#{file_name}"
    text_column             = generate_column(section_name,
                                              "#{section_name}_text", content,
                                              nil, nil, 1, text_width)
    image_column            = generate_column(section_name, "#{section_name}_image",
                                              additional_text, image_tag,
                                              image_link, 2, image_width, "image")

    [ text_column, image_column ]
  end

  def generate_column_from_text_section(column_name, column_order = 1, width = "100%")
    generate_column_from_section(column_name, column_order, width)
  end

  def generate_column_from_image_section(column_name, column_order = 1, width = "100%")
    generate_column_from_section(column_name, column_order, width, "image")
  end

  def generate_columns_from_split_section(image_left = true)
    text_width  = "50%"
    image_width = "50%"

    if formatting.present? &&
      (formatting["text_classes"].present? ||
        formatting["image_classes"].present?)
      text_width, image_width = get_percentages(formatting["text_classes"],
                                                formatting["image_classes"])
    end

    if image_left
      image_column = generate_column_from_image_section("#{section_name}_image",
                                                        1, image_width)
      text_column  = generate_column_from_text_section("#{section_name}_text",
                                                       2, text_width)
    else
      text_column  = generate_column_from_text_section("#{section_name}_text",
                                                       1, text_width)
      image_column = generate_column_from_image_section("#{section_name}_image",
                                                        2, image_width)
    end

    if text_column.present? && !text_column.image.present? && !text_column.content.present?
      text_column.column_type = "blank"
      text_column.column_name = "#{section_name}_place-holder"
    end

    [ text_column, image_column ]
  end

  def generate_column_from_text_single
    generate_column_from_text_section(section_name)
  end

  def generate_column_from_image_single
    generate_column_from_image_section(section_name, 1, "100%")
  end

  def generate_columns_from_text_left
    generate_columns_from_split_section(false)
  end

  def generate_columns_from_image_left
    generate_columns_from_split_section(true)
  end

  def generate_columns_from_text_right
    generate_columns_from_split_section(true)
  end

  def generate_columns_from_image_right
    generate_columns_from_split_section(false)
  end

  def generate_columns_from_text_top
    text_column  = generate_column_from_text_section("#{section_name}_text")
    image_column = generate_column_from_image_section("#{section_name}_image")

    [ text_column, image_column ]
  end

  def generate_columns_from_text_bottom
    text_column  = generate_column_from_text_section("#{section_name}_text")
    image_column = generate_column_from_image_section("#{section_name}_image")

    [ text_column, image_column ]
  end

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
    text_width    = Regexp.last_match(1).to_i if text_classes.present? && text_classes =~ /col-(\d{1,2})/
    image_width   = Regexp.last_match(1).to_i if image_classes.present? && image_classes =~ /col-(\d{1,2})/

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

    closest_text_ratio  = ratios.keys.min_by { |key| (text_percentage - key).abs } || 0
    closest_image_ratio = ratios.keys.min_by { |key| (image_percentage - key).abs } || 0
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
