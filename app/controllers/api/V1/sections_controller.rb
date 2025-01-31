# frozen_string_literal: true

# app/controllers/api/home_contents_controller.rb
module Api
  module V1
    class SectionsController < ApplicationController
      def index
        sections = Section.all

        render json: sections
      end
    end
  end
end
