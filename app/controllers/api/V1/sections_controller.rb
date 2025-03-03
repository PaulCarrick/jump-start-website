# frozen_string_literal: true

# app/controllers/api/home_contents_controller.rb
module Api
  module V1
    class SectionsController < ApplicationController
      def index
        sections = Section.all

        render json: sections
      end

      def get_admin_urls
        urls          = {}
        index_url     = admin_sections_url
        urls[:index]  = { url: index_url, method: "GET" }
        urls[:return] = { url: index_url, method: "GET" }
        urls[:submit] = { url: index_url, method: "POST" }
        urls[:cancel] = { url: index_url, method: "GET" }

        if params[:id] =~ /^\d+$/
          section_id = params[:id]
        else
          section_id = nil
        end

        if section_id.present?
          record_exists = Section.exists?(section_id)
          urls[:submit] = { url:    (record_exists ? admin_section_url(section_id) : index_url),
                            method: (record_exists ? "PATCH" : "POST") }
          urls[:view]   = { url: admin_section_url(section_id), method: "GET" }
          urls[:edit]   = { url: edit_admin_section_url(section_id), method: "GET" }
          urls[:delete] = { url: admin_delete_section_url(section_id), method: "DELETE" }
        end

        render json: urls
      end
    end
  end
end
