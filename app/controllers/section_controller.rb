class SectionController < ApplicationController
  include HtmlSanitizer

  def index
    @q = Section.ransack(params[:q])
    @pagy, @results = pagy(@q.result(distinct: true), limit: 3)
    @sections = []
    previous_order = nil
    previous_type = nil
    index = 0

    @results.each do |section|
      page = Page.by_section(section.content_type)

      next unless page.present?

      index = 0 if (section.content_type != previous_type) || (section.section_order != previous_order)
      previous_order = section.section_order
      previous_type = section.content_type
      @page = page[0]

      row = {
        title: @page.title,
        description: sanitize_html(section.description),
        url: page_path(@page.name, section_name: section.section_name),
        index: index
      }

      @sections << row
      index += 1
    end
  end
end
