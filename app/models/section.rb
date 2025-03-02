# app/models/section.rb

class Section < ApplicationRecord
  has_many :cells, -> { order(cell_order: :asc) }, foreign_key: "section_name", primary_key: "section_name", dependent: :destroy

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

  def renderable_section
    self.as_json(include: :cells)
  end

  def generate_cells
    begin
      row_style    = formatting["row_style"] if formatting
      section_name = content_type unless section_name.present?

      if image&.start_with?("ImageSection:") # Special case
        image_section         = image[13..-1]
        text_cell, image_cell = generate_cells_from_image_section(image_section)

        text_cell.save!
        image_cell.save!
      else
        if row_style.present?
          case row_style

          when 'text-single'
            cell = generate_cell_from_text_single

            cell.save! if cell.present?

          when 'text-left'
            text_cell, image_cell = generate_cells_from_text_left

            text_cell.save!
            image_cell.save!

          when 'image-left'
            text_cell, image_cell = generate_cells_from_image_left

            image_cell.save!
            text_cell.save!

          when 'text-right'
            text_cell, image_cell = generate_cells_from_text_right

            image_cell.save!
            text_cell.save!

          when 'image-right'
            text_cell, image_cell = generate_cells_from_image_right

            text_cell.save!
            image_cell.save!

          when 'text-top'
            text_cell, image_cell = generate_cells_from_text_top

            text_cell.save!
            image_cell.save!

          when 'text-bottom'
            text_cell, image_cell = generate_cells_from_text_bottom

            image_cell.save!
            text_cell.save!
          else
            cell = generate_cell_from_text_single

            cell.save! if cell.present?
          end
        else
          cell = generate_cell_from_text_single

          cell.save! if cell.present?
        end
      end
    rescue => e
      errors.add(:base, "Cannot generate cells from: #{section_name}..Error: #{e.message}")

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

  def configure_formatting(formatting, cell, cell_type = "text")
    return unless formatting.present?

    cell.formatting   = formatting
    expanding_cells   = nil
    container_classes = nil
    classes           = nil
    styles            = nil

    cell.formatting.each do |key, value|
      case key
      when "image_classes"
        if cell_type == "image"
          classes = value
          styles  = value
        end
      when "text_classes"
        if cell_type != "image"
          classes = value
          styles  = value
        end
      when "row_classes"
        container_classes = value.gsub("Row", "Cell")
      when "div_ratio"
        if formatting["row_style"] == "text-left"
          if cell_type == "image"
            _, image_width = value.split(':')
            cell.width     = "image_width" + "%"
          else
            text_width, _ = value.split(':')
            cell.width    = "text_width" + "%"
          end
        elsif formatting["row_style"] == "text-right"
          if cell_type == "image"
            image_width, _ = value.split(':')
            cell.width     = "image_width" + "%"
          else
            _, text_width = value.split(':')
            cell.width    = "text_width" + "%"
          end
        end
      when "expanding_rows"
        expanding_cells = value.gsub("Row", "Cell")
      end
    end

    cell.formatting["classes"]           = classes unless classes.nil?
    cell.formatting["styles"]            = styles unless styles.nil?
    cell.formatting["container_classes"] = container_classes unless container_classes.nil?

    cell.formatting.delete("row_style") # Not used
    cell.formatting.delete("row_classes") # Not used
    cell.formatting.delete("div_ratio") # Not used
    cell.formatting.delete("text_styles") # Not used
    cell.formatting.delete("text_classes") # Not used
    cell.formatting.delete("image_styles") # Not used
    cell.formatting.delete("image_classes") # Not used
    cell.formatting.delete("expanding_rows") # Not used

    if expanding_cells.present?
      if image&.start_with?("ImageSection:")
        cell.formatting["expanding_cells"] = expanding_cells if cell_type != "text"
      else
        cell.formatting["expanding_cells"] = expanding_cells
      end
    end
  end

  def generate_cell(section_name, cell_name, description, image, link,
                    cell_order = 1, width = "100%", cell_type = "text")
    cell              = Cell.new
    cell.section_name = section_name
    cell.cell_name    = cell_name
    cell.cell_type    = cell_type
    cell.cell_order   = cell_order
    cell.content      = description if cell_type == "text" || self.image&.start_with?("ImageSection:")
    cell.image        = image if cell_type == "image"
    cell.link         = link if cell_type == "image"
    cell.width        = width

    configure_formatting(formatting, cell, cell_type) if formatting.present?

    cell
  end

  def generate_cell_from_section(cell_name,
                                 cell_order = 1,
                                 width = "100%",
                                 cell_type = "text")
    generate_cell(section_name, cell_name, description, image, link,
                  cell_order, width, cell_type)
  end

  def generate_cells_from_image_section(file_name)
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
    text_cell               = generate_cell(section_name,
                                            "#{section_name}_text", content,
                                            nil, nil, 1, text_width)
    image_cell              = generate_cell(section_name, "#{section_name}_image",
                                            additional_text, image_tag,
                                            image_link, 2, image_width, "image")

    [ text_cell, image_cell ]
  end

  def generate_cell_from_text_section(cell_name, cell_order = 1, width = "100%")
    generate_cell_from_section(cell_name, cell_order, width)
  end

  def generate_cell_from_image_section(cell_name, cell_order = 1, width = "100%")
    generate_cell_from_section(cell_name, cell_order, width, "image")
  end

  def generate_cells_from_split_section(image_left = true)
    text_width  = "50%"
    image_width = "50%"

    if formatting.present? &&
      (formatting["text_classes"].present? ||
        formatting["image_classes"].present?)
      text_width, image_width = get_percentages(formatting["text_classes"],
                                                formatting["image_classes"])
    end

    if image_left
      image_cell = generate_cell_from_image_section("#{section_name}_image",
                                                    1, image_width)
      text_cell  = generate_cell_from_text_section("#{section_name}_text",
                                                   2, text_width)
    else
      text_cell  = generate_cell_from_text_section("#{section_name}_text",
                                                   1, text_width)
      image_cell = generate_cell_from_image_section("#{section_name}_image",
                                                    2, image_width)
    end

    if text_cell.present? && !text_cell.image.present? && !text_cell.content.present?
      text_cell.cell_type = "blank"
      text_cell.cell_name = "#{section_name}_place-holder"
    end

    [ text_cell, image_cell ]
  end

  def generate_cell_from_text_single
    generate_cell_from_text_section(section_name)
  end

  def generate_cell_from_image_single
    generate_cell_from_image_section(section_name, 1, "100%")
  end

  def generate_cells_from_text_left
    generate_cells_from_split_section(false)
  end

  def generate_cells_from_image_left
    generate_cells_from_split_section(true)
  end

  def generate_cells_from_text_right
    generate_cells_from_split_section(true)
  end

  def generate_cells_from_image_right
    generate_cells_from_split_section(false)
  end

  def generate_cells_from_text_top
    text_cell  = generate_cell_from_text_section("#{section_name}_text")
    image_cell = generate_cell_from_image_section("#{section_name}_image")

    [ text_cell, image_cell ]
  end

  def generate_cells_from_text_bottom
    text_cell  = generate_cell_from_text_section("#{section_name}_text")
    image_cell = generate_cell_from_image_section("#{section_name}_image")

    [ text_cell, image_cell ]
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
