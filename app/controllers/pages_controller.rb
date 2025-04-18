# frozen_string_literal: true

# app/controllers/pages_controller.rb

include HtmlSanitizer

class PagesController < ApplicationController
  def show
    load_page
  end

  private

  def load_page
    return if params[:id].present? && params[:id] =~ /^favicon.*$/

    @page = Page.by_page_name(params[:id]).first

    if @page.present?
      setup_defaults

      @contents = build_contents

      process_video_images

      renderable_contents = []

      @contents.each do |section|
        renderable_contents << section.renderable_section
      end

      @contents = renderable_contents
    else
      flash[:alert] = "Can't find page for: #{params[:id]}."
    end
  end

  def setup_defaults
    @missing_image ||= view_context.image_path("missing-image.jpg")
  end

  def build_contents
    contents = []
    sections = Section.by_content_type(@page.section)

    set_focused_section(sections)

    sections.each do |section|
      subsection = process_section(section)
      contents << section
      contents << subsection if subsection.present? && !section.cells.present?
    end

    contents
  end

  def set_focused_section(sections)
    return unless params[:section_name].present?

    @focused_section = sections.find { |section| section.section_name == params[:section_name] }
  end

  def process_section(section)
    return unless section.image.present?

    images, description, formatting, subsection = process_image(section)
    section.image                               = images
    section.description                         = description
    section.formatting                          = formatting

    subsection
  end

  def process_image(section)
    images      = section.image.dup.strip
    description = sanitize_html(section.description)
    formatting  = section.formatting
    subsection  = nil

    case images
    when /^\s*ImageGroup:\s*(.+)\s*$/
      images, description, formatting = handle_image_group(Regexp.last_match(1), formatting)
    when /^\s*ImageFile:\s*(.+)\s*$/
      images = handle_single_image_file(section, Regexp.last_match(1))
    when /^\s*ImageSection:\s*(.+)\s*$/
      images, description, subsection, formatting = handle_image_section(section, Regexp.last_match(1), formatting)
    when /^\s*\[\s*(.+?)\s*\]\s*$/m
      images, formatting = handle_image_array(Regexp.last_match(1), formatting)
    else
      images = get_image_path(images)
    end

    [ images, description, formatting, subsection ]
  end

  def handle_image_group(group_name, formatting)
    image_files = ImageFile.by_image_group(group_name)

    if image_files.present?
      formatting = add_images_to_formatting(formatting, image_files)

      [ nil, "", formatting ]
    else
      [ @missing_image, "", formatting ]
    end
  end

  # TO DO This is a really ugly hack, but at the moment I don't know how to fix it and it's only for testing.
  # The issue is the test environment isn't running on localhost but in the test environment and nothing I did
  # changing the test config in config/environments or changing the test environment in RSpec would fix it.
  # We get the current path and replace it with the test environment host and port.
  def get_image_url(image_file)
    results = nil

    if Rails.env == "test" && ENV['IMAGE_HACK'] && image_file.present?
      results = image_file.image_url

      if results.present?
        image_uri      = URI.parse(results)
        current_uri    = URI.parse(request.url)
        image_uri.host = current_uri.host
        image_uri.port = current_uri.port
        results        = image_uri.to_s
      end
    else
      results = image_file&.image_url
    end

    results ||= @missing_image
  end

  def handle_single_image_file(section, file_name)
    image_file   = ImageFile.find_by(name: file_name)
    results      = get_image_url(image_file)
    section.link = results

    results
  end

  def handle_image_section(section, file_name, formatting)
    image_file = ImageFile.find_by(name: file_name)
    image_url  = get_image_url(image_file)

    if image_url.present?
      section.link = image_url
      caption      = image_file.caption.to_s

      # Check if caption contains only <p> tags or no HTML
      if caption.match?(/\A(\s*<p>.*?<\/p>\s*)*\z/i)
        description = sanitize_html("<div class='display-4 fw-bold mb-1 text-dark'>#{caption}</div>")
      else
        description = caption
      end

      subsection, formatting = build_subsection(section, image_file, formatting)

      [ image_url, description, subsection, formatting ]
    else
      [ @missing_image, "", nil, nil ]
    end
  end

  def build_subsection(section, image_file, formatting)
    subsection             = section.deep_dup
    subsection.link        = nil
    subsection.image       = nil
    subsection.formatting  = flip_formatting_side(formatting)
    subsection.description = image_file.description

    if formatting.include?('expanding_rows')
      formatting.delete("expanding_rows")
    end

    [ subsection, formatting ]
  end

  def handle_image_array(image_list, formatting)
    images = image_list.split(",").map { |image_name| ImageFile.find_by_name(image_name) }
    [ nil, add_images_to_formatting(formatting, images) ]
  end

  def process_video_images
    @contents.each do |content|
      next unless content.description =~ /VideoImage:\s*"(.+)"/

      replace_video_image_tag(content, Regexp.last_match(1))
    end
  end

  def replace_video_image_tag(content, file_name)
    image_file = ImageFile.find_by(name: file_name)
    image_url  = get_image_url(image_file)

    if image_url.present?
      label = image_file.caption
      label = image_file.name unless label.present?

      video_tag = view_context.link_to(label,
                                       '#',
                                       onclick: "showVideoPlayer('#{image_url}')")
      content.description.gsub!(/VideoImage:\s*"(.+)"/, video_tag)
    end
  end

  def get_image_path(image_url)
    image_url.strip!

    if image_url =~ /^\s*http/i
      image_url
    else
      view_context.image_path(image_url)
    end
  rescue
    @missing_image
  end

  def flip_formatting_side(formatting)
    return { row_style: "text-right" } unless formatting.present?

    new_formatting = formatting.deep_dup

    if new_formatting['row_style'] == "text-left"
      new_formatting['row_style'] = "text-right"
      swap_classes!(new_formatting)
    else
      new_formatting['row_style'] = "text-left"
      swap_classes!(new_formatting)
    end
  end

  def swap_classes!(formatting)
    if formatting["text_classes"].present? && formatting["image_classes"].present?
      formatting["image_classes"].gsub!(/w-\d\d|w-\d\d\d/, "")
      formatting["text_classes"], formatting["image_classes"] = formatting["image_classes"],
        formatting["text_classes"]
    end

    if formatting["row_classes"].present?
      formatting["row_classes"].gsub!(/mt-\d|pt-\d/, "")
    end

    formatting
  end

  def add_images_to_formatting(formatting, images)
    formatting["slide_show_images"] = images.map do |image|
      {
        image_url:   image.image_url,
        caption:     image.caption,
        description: image.description
      }
    end

    formatting
  end
end
