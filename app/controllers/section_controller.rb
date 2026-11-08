class SectionController < ApplicationController
  include HtmlSanitizer

  EXCERPT_LENGTH = 400

  # Site search. Looks at the text visitors see: each section's description
  # and the content of its columns.
  def index
    @query   = params.dig(:q, :description_cont).to_s.strip
    @q       = Section.enabled.joins(:page).where(pages: { enabled: true }).ransack(params[:q]&.except(:description_cont))
    sections = @q.result(distinct: true)

    if @query.present?
      pattern        = "%#{Section.sanitize_sql_like(@query)}%"
      matching_cells = Cell.enabled.where("cells.content ILIKE ?", pattern).select(:section_id)
      sections       = sections.where("sections.description ILIKE ?", pattern).or(sections.where(id: matching_cells))
    end

    @pagy, @results = pagy(sections.distinct.order(:content_type, :section_order, :id), limit: 3)
    @sections = []
    previous_order = nil
    previous_type = nil
    index = 0

    @results.each do |section|
      page = Page.enabled.by_section(section.content_type)

      next unless page.present?

      index = 0 if (section.content_type != previous_type) || (section.section_order != previous_order)
      previous_order = section.section_order
      previous_type = section.content_type
      @page = page[0]

      row = {
        title: @page.title,
        description: sanitize_html(matching_text(section)),
        url: page_path(@page.name, section_name: section.section_name),
        index: index
      }

      @sections << row
      index += 1
    end
  end

  private

  # The section's description when it contains the words, otherwise the
  # first column that does.
  def matching_text(section)
    description = section.description.to_s
    words       = @query.downcase

    return description if words.blank? || description.downcase.include?(words)

    cell = section.cells.enabled.find { |candidate| candidate.content.to_s.downcase.include?(words) }
    cell.present? ? Utilities.truncate_html(cell.content, EXCERPT_LENGTH) : description
  end
end
