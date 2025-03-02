# app/controllers/cells_controller.rb

class CellsController < ApplicationController
  include HtmlSanitizer

  def index
    @q = Cell.ransack(params[:q])
    @pagy, @results = pagy(@q.result(distinct: true), limit: 3)

    @results
  end
end
