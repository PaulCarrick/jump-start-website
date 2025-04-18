# frozen_string_literal: true

# app/controllers/api/v1/cells_controller.rb

module Api
  module V1
    class CellsController < ApplicationController
      def index
        @q            = Cell.ransack(params[:q])
        cells         = @q.result(distinct: true).order(:cell_order)
        @pagy, @cells = pagy(cells, limit: params[:limit] || 100)

        pagy_headers_merge(@pagy)

        render json: @cells.as_json
      end

      def show
        results = nil

        if params[:id] =~ /\A\d+\z/
          results = Cell.find_by(id: params[:id])
        else
          results = Cell.by_section_name(params[:id])
        end

        if results.present?
          render json: results
        else
          render json: { error: "Cell not found" }, status: :not_found
        end
      end

      def create
        cell = Cell.new(get_params)

        if cell.save
          render json: cell, status: :created
        else
          render json: { errors: cell.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        cell = Cell.find_by(id: params[:id])

        if cell && cell.update(get_params)
          render json: cell
        else
          render json: { errors: cell&.errors&.full_messages || [ "Cell not found" ] }, status: :unprocessable_entity
        end
      end

      def destroy
        cell = Cell.find_by(id: params[:id])

        if cell
          cell.destroy
          render json: { message: "Cell deleted successfully" }
        else
          render json: { error: "Cell not found" }, status: :not_found
        end
      end

      def get_admin_urls
        urls          = {}
        index_url     = admin_cells_url
        urls[:index]  = { url: index_url, method: "GET" }
        urls[:new]    = { url: new_admin_cell_url, method: "POST" }
        urls[:return] = { url: index_url, method: "GET" }
        urls[:submit] = { url: index_url, method: "POST" }
        urls[:cancel] = { url: index_url, method: "GET" }
        cell_id = Integer(params[:id]) rescue nil

        if cell_id.present? && Cell.exists?(cell_id)
          urls[:submit] = { url: admin_cell_url(cell_id), method: "PATCH" }
          urls[:view]   = { url: admin_cell_url(cell_id), method: "GET" }
          urls[:edit]   = { url: edit_admin_cell_url(cell_id), method: "GET" }
          urls[:delete] = { url: admin_delete_cell_url(cell_id), method: "DELETE" }
        end

        render json: urls
      end

      private

      def get_params
        params.require(:cell).permit(
          :cell_name,
          :section_name,
          :type,
          :cell_order,
          :content,
          :image,
          :link,
          :width,
          :checksum,
          options:    {},
          formatting: {}
        )
      end
    end
  end
end
