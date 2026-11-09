# app/models/section.rb

# noinspection RubyTooManyMethodsInspection
class Section < ApplicationRecord
  include Enableable
  include BitemporalRecord
  has_many :cells, -> { order(cell_order: :asc) }, dependent: :destroy, primary_key: :id, foreign_key: :section_id, inverse_of: :section
  accepts_nested_attributes_for :cells, allow_destroy: true
  belongs_to :page, primary_key: :id, foreign_key: :page_id, inverse_of: :sections

  after_find :verify_checksum, unless: -> { Thread.current[:skip_checksum_verification] }
  after_find :setup_formatting
  after_update :rename_cells, if: :saved_change_to_section_name?

  include Checksum
  include Validation

  scope :by_content_type, ->(type) {
    where(content_type: type)
      .order(:section_order)
      .includes(:cells)
      .references(:cells)
      .order("cells.cell_order ASC")
  }
  scope :content_types, ->() { all.distinct.order(:content_type).pluck(:content_type) }
  scope :names, ->() { all.distinct.order(:section_name).pluck(:section_name) }

  validates :section_name, presence: true, uniqueness: { conditions: -> { working_or_live } }
  validates :section_name, format: { with: /\A[\w\-. ]+\z/, message: "can only use letters, numbers, spaces, dots, dashes and underscores" }, allow_blank: true, if: :section_name_changed?

  def self.ransackable_attributes(auth_object = nil)
    %w[content_type section_name image link description]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def renderable_section(public_view: false)
    data = as_json(include: :cells)
    data["cells"] = cells.enabled.as_json if public_view
    data
  end

  # Copies this section, or its whole group, to the end of the page.
  #
  # One section (group: false): the copy is named +name+, belongs to no group,
  # and its columns are named after it.
  # A group (group: true): +name+ is the new group's name and is put in front
  # of each section's name ("ibi" copies "ibi-description" as
  # "ibi2-ibi-description" for the name "ibi2"). The copies' Show More buttons
  # get classes of their own, so they open their own hidden parts, not the
  # original's.
  #
  # Returns the copies, in page order. Raises ActiveRecord::RecordInvalid with
  # a plain message when a name is not allowed or already taken.
  def duplicate!(name:, group: section_group.present?)
    self.class.transaction do
      Page.lock.find(page_id)
      source = self.class.lock.find(id)
      name = name.to_s.squish
      whole_group = group && source.section_group.present?
      members = if whole_group
                  self.class.where(page_id: source.page_id, section_group: source.section_group)
                            .order(self.class.arel_table[:section_order].asc.nulls_last, self.class.arel_table[:id].asc)
                            .lock.to_a
      else
                  [ source ]
      end
      new_names = members.map { |member| whole_group ? "#{name}-#{member.section_name}" : name }

      problem = duplicate_name_problem(name, new_names, whole_group, source.page_id)
      if problem
        source.errors.add(:base, problem)
        raise ActiveRecord::RecordInvalid.new(source)
      end

      last_order = self.class.where(page_id: source.page_id).maximum(:section_order).to_i
      suffix = whole_group ? name.gsub(/[^A-Za-z0-9]/, "").camelize.presence || "Copy" : nil
      reserved_cell_names = []
      members.each_with_index.map do |member, index|
        duplicate_record!(member, name: new_names[index], group: whole_group ? name : nil,
                                  section_order: last_order + (index + 1) * 10,
                                  expandable_suffix: suffix, reserved_cell_names: reserved_cell_names)
      end
    end
  end

  # Renames a group and its sections together (from the page workspace or
  # after duplicating). +names+ maps section ids to their new names.
  def self.rename_group!(page_id:, group:, new_group:, names:)
    transaction do
      Page.lock.find(page_id)
      members = where(page_id: page_id, section_group: group).lock.to_a
      raise ActiveRecord::RecordNotFound, "No group #{group} on this page" if members.empty?

      new_group = new_group.to_s.squish
      wanted = members.to_h { |member| [ member.id, names.fetch(member.id.to_s, names.fetch(member.id, member.section_name)).to_s.squish ] }
      errors = []
      errors << "The group needs a name." if new_group.blank?
      errors << "The group name can only use letters, numbers, spaces, dots, dashes and underscores." if new_group.present? && new_group !~ /\A[\w\-. ]+\z/
      if new_group != group && where(page_id: page_id, section_group: new_group).exists?
        errors << "There is already a group called #{new_group} on this page."
      end
      wanted.each_value do |section_name|
        errors << "Each section needs a name." if section_name.blank?
        errors << "#{section_name} can only use letters, numbers, spaces, dots, dashes and underscores." if section_name.present? && section_name !~ /\A[\w\-. ]+\z/
      end
      errors << "Two sections cannot have the same name." if wanted.values.uniq.size != wanted.size
      taken = where(section_name: wanted.values).where.not(id: members.map(&:id)).pluck(:section_name)
      errors << "#{taken.to_sentence} #{taken.size == 1 ? 'is' : 'are'} already used by another section." if taken.any?
      if errors.any?
        members.first.errors.add(:base, errors.uniq.join(" "))
        raise ActiveRecord::RecordInvalid.new(members.first)
      end

      # Free the names first, so two sections can swap names.
      changing = members.select { |member| member.section_name != wanted[member.id] }
      changing.each { |member| member.update!(section_name: "#{member.section_name}-renaming-#{member.id}") }
      members.each do |member|
        member.reload
        member.update!(section_name: wanted[member.id], section_group: new_group)
      end
      members
    end
  end

  def self.generate_unique_name(prefix = "new-section_")
    existing_names = Section.where("section_name ~ ?", "^#{prefix}\\d+$").pluck(:section_name)

    max_number = existing_names
                   .map { |name| name[/\d+\z/].to_i }
                   .max || 0

    "#{prefix}#{max_number + 1}"
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
      errors.add(:base, "Cannot generate columns from: #{section_name}..Error: #{e.message}")

      raise ActiveRecord::Rollback
    end
  end

  private

  def duplicate_name_problem(name, new_names, whole_group, page_id)
    return(whole_group ? "Please enter a name for the new group." : "Please enter a name for the copy.") if name.blank?
    unless name.match?(/\A[\w\-. ]+\z/)
      return "The name can only use letters, numbers, spaces, dots, dashes and underscores."
    end
    if whole_group && self.class.where(page_id: page_id, section_group: name).exists?
      return "There is already a group called #{name} on this page."
    end

    taken = self.class.where(section_name: new_names).pluck(:section_name)
    "#{taken.to_sentence} #{taken.size == 1 ? 'is' : 'are'} already used by another section; choose another name." if taken.any?
  end

  def duplicate_record!(source, name:, group:, section_order:, expandable_suffix: nil, reserved_cell_names: [])
    # after_find derives display defaults; duplicate the stored values themselves.
    source.restore_attributes
    copy = source.dup
    copy.section_name = name
    copy.section_group = group
    copy.section_order = section_order
    copy.formatting = with_expandable_suffix(source.formatting, expandable_suffix) if expandable_suffix && copy.respond_to?(:formatting=)

    source.cells.each do |cell|
      child = cell.dup
      child.cell_name = copy_cell_name(cell.cell_name, source.section_name, name, reserved_cell_names)
      reserved_cell_names << child.cell_name
      child.section_name = copy.section_name
      child.formatting = with_expandable_suffix(cell.formatting, expandable_suffix) if expandable_suffix
      copy.cells << child
    end

    copy.save!
    copy
  end

  # A column named after its section ("ibi_text") is named after the copy
  # ("ibi2-ibi_text"); any other column name gets the copy's name in front.
  # A number is added if the name is taken.
  def copy_cell_name(original, old_section_name, new_section_name, reserved)
    original = original.to_s
    base = if old_section_name.present? && original.start_with?(old_section_name)
             new_section_name + original.delete_prefix(old_section_name)
    else
             [ new_section_name, original.presence ].compact.join("-")
    end
    candidate = base
    number = 1
    while reserved.include?(candidate) || Cell.exists?(cell_name: candidate)
      number += 1
      candidate = "#{base}-#{number}"
    end
    candidate
  end

  # "expandableIbiCells" becomes "expandableIbiCellsIbi2", wherever it appears
  # in a copy's formatting.
  def with_expandable_suffix(value, suffix)
    case value
    when Hash then value.transform_values { |inner| with_expandable_suffix(inner, suffix) }
    when Array then value.map { |inner| with_expandable_suffix(inner, suffix) }
    when String then value.gsub(/\bexpandable[A-Za-z0-9_]*/) { |found| "#{found}#{suffix}" }
    else value
    end
  end

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
          value.gsub!(/\s*w-\d{2,3}\s*/, "")

          classes = value
        end
      when "image_styles"
        if cell_type == "image"
          styles = value
        end
      when "text_classes"
        if cell_type != "image"
          value.gsub!(/\s*w-\d{2,3}\s*/, "")

          classes = value
        end
      when "text_styles"
        if cell_type != "image"
          styles = value
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
    verify_checksum_for(description)
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

  # Columns keep their section's name (the page uses it as the section's
  # anchor), so a renamed section renames them too, as drafts like any edit.
  def rename_cells
    Cell.where(section_id: id).where.not(section_name: section_name).find_each do |cell|
      cell.update!(section_name: section_name)
    end
  end
end
