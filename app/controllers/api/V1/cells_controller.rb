# frozen_string_literal: true

# app/controllers/api/home_contents_controller.rb
module Api
  module V1
    class CellsController < ApplicationController
      def index
        cells = Cell.all

        render json: cells
      end

      def get_admin_urls
        urls          = {}
        index_url     = admin_cells_url
        urls[:index]  = { url: index_url, method: "GET" }
        urls[:return] = { url: index_url, method: "GET" }
        urls[:submit] = { url: index_url, method: "POST" }
        urls[:cancel] = { url: index_url, method: "GET" }

        if params[:id] =~ /^\d+$/
          cell_id = params[:id]
        else
          cell_id = nil
        end

        if cell_id.present?
          record_exists = Cell.exists?(cell_id)
          urls[:submit] = { url:    (record_exists ? admin_cell_url(cell_id) : index_url),
                            method: (record_exists ? "PATCH" : "POST") }
          urls[:view]   = { url: admin_cell_url(cell_id), method: "GET" }
          urls[:edit]   = { url: edit_admin_cell_url(cell_id), method: "GET" }
          urls[:delete] = { url: admin_delete_cell_url(cell_id), method: "DELETE" }
        end

        render json: urls
      end
    end
  end
end
