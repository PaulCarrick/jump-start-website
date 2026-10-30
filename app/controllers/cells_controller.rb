# app/controllers/cells_controller.rb

class CellsController < ApplicationController
  include HtmlSanitizer

  def index
    @q = Cell.enabled.joins(section: :page).where(sections: { enabled: true }, pages: { enabled: true }).ransack(params[:q])
    @pagy, @results = pagy(@q.result(distinct: true), limit: 3)

    @cells = @results.includes(section: :page).map do |cell|
      {
        cell_name: cell.cell_name,
        content: cell.content,
        url: page_path(cell.section.page.name, section_name: cell.section.section_name)
      }
    end
  end
end
