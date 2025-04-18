# frozen_string_literal: true

# app/controllers/api/v1/pages_controller.rb

module Api
  module V1
    class PagesController < ApplicationController
      def index
        @q            = Page.ransack(params[:q])
        pages         = @q.result(distinct: true)
                          .includes(:sections)
                          .order(:section_order)
        @pagy, @pages = pagy(pages, limit: params[:limit] || 100)

        pagy_headers_merge(@pagy)

        render json: @pages.as_json
      end

      def show
        if params[:id].kind_of?(String)
          results = Page.by_page_name(params[:id]).first
        else
          results = Page.by_id(params[:id]).first
        end

        if results.present?
          render json: results
        else
          render json: { error: "Page not found" }, status: :not_found
        end
      end

      def create
        page = Page.new(get_params)

        begin
          if page.save
            render json: page, status: :created
          else
            render json: { errors: page.errors.full_messages }, status: :unprocessable_entity
          end
        rescue => e
          render json: { errors: e.message }, status: :unprocessable_entity
        end
      end

      def update
        if page.update(get_params)
          render json: page
        else
          render json: { errors: page&.errors&.full_messages || [ "Page not found" ] }, status: :unprocessable_entity
        end
      end

      def destroy
        begin
          if Page.destroy(params[:id])
            render json: { message: "Page deleted successfully" }
          else
            render json: { error: "Page: #{params[:id]} can't be deleted" }, status: :not_found
          end
        rescue => e
          render json: { error: "Page: #{params[:id]} can't be deleted. Error: #{e.message}." }, status: :not_found
        end
      end

      def get_admin_urls
        urls          = {}
        index_url     = admin_pages_url
        urls[:index]  = { url: index_url, method: "GET" }
        urls[:new]    = { url: new_admin_page_url, method: "POST" }
        urls[:return] = { url: index_url, method: "GET" }
        urls[:submit] = { url: index_url, method: "POST" }
        urls[:cancel] = { url: index_url, method: "GET" }
        page_id = Integer(params[:id]) rescue nil

        if page_id.present? && Page.exists?(page_id)
          urls[:submit] = { url: admin_page_url(page_id), method: "PATCH" }
          urls[:view]   = { url: admin_page_url(page_id), method: "GET" }
          urls[:edit]   = { url: edit_admin_page_url(page_id), method: "GET" }
          urls[:delete] = { url: admin_delete_page_url(page_id), method: "DELETE" }
        end

        render json: urls
      end

      private

      def get_params
        params.require(:page).permit(
          :id,
          :name,
          :section,
          :title,
          :access,
          sections_attributes: [
                                 :id,
                                 :content_type,
                                 :section_name,
                                 :section_order,
                                 :image,
                                 :link,
                                 :description,
                                 :checksum,
                                 :row_style,
                                 :div_ratio,
                                 :_destroy,
                                 { image_attributes: {}, text_attributes: {}, formatting: {} }, # Moved hash attributes inside {}
                                 cells_attributes: [
                                                     :id,
                                                     :section_name,
                                                     :cell_name,
                                                     :cell_type,
                                                     :cell_order,
                                                     :content,
                                                     :image,
                                                     :link,
                                                     :width,
                                                     :checksum,
                                                     :_destroy,
                                                     options:    {},
                                                     formatting: {}
                                                   ]
                               ]
        )
      end
    end
  end
end
