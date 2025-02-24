# frozen_string_literal: true

# app/controllers/api/home_contents_controller.rb
module Api
  module V1
    class ColumnsController < ApplicationController
      def index
        columns = Column.all

        render json: columns
      end
    end
  end
end
