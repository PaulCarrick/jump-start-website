# app/controllers/columns_controller.rb

class ColumnsController < ApplicationController
  include HtmlSanitizer

  def index
    @q = Column.ransack(params[:q])
    @pagy, @results = pagy(@q.result(distinct: true), limit: 3)

    @results
  end
end
