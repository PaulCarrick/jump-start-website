# frozen_string_literal: true

# app/controllers/api/home_contents_controller.rb
module Api
  module V1
    class CellsController < ApplicationController
      def index
        cells = Cell.all

        render json: cells
      end
    end
  end
end
