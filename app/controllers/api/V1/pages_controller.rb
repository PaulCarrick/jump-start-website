# app/controllers/api/pages_controller.rb
module Api
  module V1
    class PagesController < ApplicationController
      def index
        pages = Page.all

        render json: pages
      end
    end
  end
end
