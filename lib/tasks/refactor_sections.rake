# lib/tasks/html.rake

namespace :sections do
  desc "Convert sections to columns."
  task :convert, [ :verbose, :interactive, :debug ] => :environment do |_, args|
    args.with_defaults(verbose: false, interactive: false, debug: false)

    # Invoke subtasks with the interactive argument
    Rake::Task["sections:generate_columns"].invoke(args[:interactive], args[:debug])

    puts "Finished Converting Sections to Columns."
  end

  desc "Generate columns from sections"
  task :generate_columns, [ :verbose, :interactive, :debug ] => :environment do |_, args|
    args.with_defaults(verbose: false, interactive: false, debug: false)

    verbose = args[:verbose]

    puts "Generating columns from sections: #{args[:verbose]}"

    ActiveRecord::Base.transaction do
      debugger if args[:debug]

      Column.delete_all

      Section.find_each(batch_size: 1000) do |section|
        begin
          row_style            = section.formatting["row_style"] if section.formatting
          section.section_name = section.content_type unless section.section_name.present?

          puts "Processing Section: #{section.section_name}. Row Style: #{row_style}" if args[:verbose]

          if row_style.present?
            case row_style

            when 'text-single'
              column = generate_column_from_text_single(section)

              save_column(column, verbose)

            when 'text-left'
              text_column, image_column = generate_columns_from_text_left(section)

              save_column(text_column, verbose)
              save_column(image_column, verbose)

            when 'image-left'
              text_column, image_column = generate_columns_from_image_left(section)

              save_column(image_column, verbose)
              save_column(text_column, verbose)

            when 'text-right'
              text_column, image_column = generate_columns_from_text_right(section)

              save_column(image_column, verbose)
              save_column(text_column, verbose)

            when 'image-right'
              text_column, image_column = generate_columns_from_image_right(section)

              save_column(text_column, verbose)
              save_column(image_column, verbose)

            when 'text-top'
              text_column, image_column = generate_columns_from_text_top(section)

              save_column(text_column, verbose)
              save_column(image_column, verbose)

            when 'text-bottom'
              text_column, image_column = generate_columns_from_text_bottom(section)

              save_column(image_column, verbose)
              save_column(text_column, verbose)
            else
              column = generate_column_from_text_single(section)

              save_column(column, verbose)
            end
          else
            column = generate_column_from_text_single(section)

            save_column(column, verbose)
          end
        rescue => e
          identifier = "(#{section.id} - #{section.content_type} #{section.section_order})"

          display_error(e, section, identifier, section.description, section.formatting)

          # Call prompt only if interactive mode is enabled
          prompt if args[:interactive]

          raise ActiveRecord::Rollback
        end
      end
    end
  end

  def display_error(error, object, identifier, html, json = nil)
    error_message = object.errors.full_messages.join(', ')
    error_message = error.message unless error_message.present?
    puts "Can't save #{object.class.name}: #{identifier}, Error: #{error_message}"
    puts json if json.present?
    puts Utilities.pretty_print_html(html)
  end

  def prompt(message = "Press enter to continue...")
    print "#{message}: " # Display the prompt message
    STDIN.gets.chomp # Explicitly read from STDIN to capture input
  end

  def save_column(column, interactive = false)
    return unless column.present?
    return unless column.content.present? || column.image.present?

    column.save!

    return unless interactive

    puts "Created Column: #{column.column_name} for Section: #{column.section_name}."
    puts "                Column Type: #{column.column_type}"
    puts "                Column Order: #{column.column_order}"
    puts "                Contents: #{column.content.truncate(50)}"
    puts "                Image: #{column.image}"
    puts "                Link: #{column.link}"
    puts "                Link: #{column.width}"
    puts "                Styles: #{column.formatting.to_json}"
  end

  def get_percentages(text_classes, image_classes)
    results = [ nil, nil ]

    return results unless text_classes.present? || image_classes.present?

    text_width  = Regexp.last_match(1).to_i if text_classes.present? && text_classes =~ /col-(\d{1,2})/
    image_width = Regexp.last_match(1).to_i if image_classes.present? && image_classes =~ /col-(\d{1,2})/

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

  def setup_formatting(formatting, column, column_type = "text")
    return unless formatting.present?

    column.formatting = formatting
    classes = nil
    styles = nil

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
    column.formatting.delete("text_columns") # Not used
    column.formatting.delete("image_styles") # Not used
    column.formatting.delete("image_columns") # Not used
  end

  def generate_column_from_section(section,
                                   column_name,
                                   column_order = 1,
                                   width = "100%",
                                   column_type = "text")
    return nil unless section.present?

    column              = Column.new
    column.section_name = section.section_name
    column.column_name  = column_name
    column.column_type  = column_type
    column.column_order = column_order
    column.content      = section.description if column_type == "text"
    column.image        = section.image if column_type == "image"
    column.link         = section.link if column_type == "image"
    column.width        = width

    setup_formatting(section.formatting, column, column_type) if section.formatting.present?

    column
  end

  def generate_column_from_text_section(section, column_name, column_order = 1, width = "100%")
    return nil unless section.present?

    generate_column_from_section(section, column_name, column_order, width)
  end

  def generate_column_from_image_section(section, column_name, column_order = 1, width = "100%")
    return nil unless section.present?

    generate_column_from_section(section, column_name, column_order, width, "image")
  end

  def generate_columns_from_split_section(section, image_left = true)
    return [ nil, nil ] unless section.present?

    text_width  = "50%"
    image_width = "50%"

    if section.formatting.present? &&
      (section.formatting["text_classes"].present? ||
        section.formatting["image_classes"].present?)
      text_width, image_width = get_percentages(section.formatting["text_classes"],
                                                section.formatting["image_classes"])
    end

    if image_left
      image_column = generate_column_from_image_section(section, "#{section.section_name}_image",
                                                        1, image_width)
      text_column  = generate_column_from_text_section(section, "#{section.section_name}_text",
                                                       2, text_width)
    else
      text_column  = generate_column_from_text_section(section, "#{section.section_name}_text",
                                                       1, text_width)
      image_column = generate_column_from_image_section(section, "#{section.section_name}_image",
                                                        2, image_width)
    end

    [ text_column, image_column ]
  end

  def generate_column_from_text_single(section)
    return nil unless section.present?

    generate_column_from_text_section(section, section.section_name)
  end

  def generate_column_from_image_single(section)
    return nil unless section.present?

    generate_column_from_image_section(section, section.section_name, 1, "100%")
  end

  def generate_columns_from_text_left(section)
    return [ nil, nil ] unless section.present?

    generate_columns_from_split_section(section, false)
  end

  def generate_columns_from_image_left(section)
    return [ nil, nil ] unless section.present?

    generate_columns_from_split_section(section, true)
  end

  def generate_columns_from_text_right(section)
    return [ nil, nil ] unless section.present?

    generate_columns_from_split_section(section, true)
  end

  def generate_columns_from_image_right(section)
    return [ nil, nil ] unless section.present?

    generate_columns_from_split_section(section, false)
  end

  def generate_columns_from_text_top(section)
    return [ nil, nil ] unless section.present?

    return columns unless section.present?

    text_column  = generate_column_from_text_section(section, "#{section.section_name}_text")
    image_column = generate_column_from_image_section(section, "#{section.section_name}_image")

    [ text_column, image_column ]
  end

  def generate_columns_from_text_bottom(section)
    return [ nil, nil ] unless section.present?

    return columns unless section.present?

    text_column  = generate_column_from_text_section(section, "#{section.section_name}_text")
    image_column = generate_column_from_image_section(section, "#{section.section_name}_image")

    [ text_column, image_column ]
  end
end
