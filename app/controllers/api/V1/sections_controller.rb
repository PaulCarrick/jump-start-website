# frozen_string_literal: true

# app/controllers/api/v1/sections_controller.rb

module Api
  module V1
    # noinspection RailsParamDefResolve
    class SectionsController < ApplicationController
      def index
        @q               = Section.ransack(params[:q])
        sections         = @q.result(distinct: true)
                             .includes(:cells)
                             .order(:section_order, "cells.cell_order")
        @pagy, @sections = pagy(sections, limit: params[:limit] || 100)

        pagy_headers_merge(@pagy)

        render json: @sections.as_json
      end

      def show
        results = if params[:id] =~ /\A\d+\z/
                    Section.find_by(id: params[:id])
                  else
                    Section.by_content_type(params[:id])
                  end

        if results.present?
          render json: results
        else
          render json: { error: "Section not found" }, status: :not_found
        end
      end

      def create
        section = Section.new(section_params)

        unless section.cells.present?
          render json: "A section must have cells to be saved.", status: :unprocessable_entity

          return
        end

        if section.save
          render json: section, status: :created
        else
          render json: { errors: section.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        section = Section.find_by(id: params[:id])

        if section&.update(section_params)
          if section.cells.blank?
            render json: { errors: [ "Section must have at least one cell" ] }, status: :unprocessable_entity
          else
            render json: section
          end
        else
          render json: { errors: section&.errors&.full_messages || [ "Section cannot be updated" ] }, status: :unprocessable_entity
        end
      end

      def destroy
        section = Section.find_by(id: params[:id])

        if section
          section.destroy
          render json: { message: "Section deleted successfully" }
        else
          render json: { error: "Section not found" }, status: :not_found
        end
      end

      def get_admin_urls
        urls          = {}
        index_url     = admin_sections_url
        urls[:index]  = { url: index_url, method: "GET" }
        urls[:new]    = { url: new_admin_section_url, method: "POST" }
        urls[:return] = { url: index_url, method: "GET" }
        urls[:submit] = { url: index_url, method: "POST" }
        urls[:cancel] = { url: index_url, method: "GET" }
        section_id = Integer(params[:id]) rescue nil

        if section_id.present? && Section.exists?(section_id)
          urls[:submit] = { url: admin_section_url(section_id), method: "PATCH" }
          urls[:view]   = { url: admin_section_url(section_id), method: "GET" }
          urls[:edit]   = { url: edit_admin_section_url(section_id), method: "GET" }
          urls[:delete] = { url: admin_delete_section_url(section_id), method: "DELETE" }
        end

        render json: urls
      end

      private

      def section_params
        section = params.require(:section)

        section[:cells_attributes] = section.delete(:cells) if section[:cells].present?

        section.permit(
          :content_type,
          :section_name,
          :section_order,
          :image,
          :link,
          :description,
          :checksum,
          :row_style,
          :div_ratio,
          image_attributes: {},
          text_attributes:  {},
          formatting:       {},
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
                              formatting: {},
                              options:    {}
                            ]
        )
      end
    end
  end
end
