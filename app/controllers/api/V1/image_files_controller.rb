# frozen_string_literal: true

# app/controllers/api/v1/image_files_controller.rb
module Api
  module V1
    class ImageFilesController < ApplicationController
      include Pagy::Backend # Include Pagy for pagination

      before_action :set_image, only: %i[ update destroy ]

      def index
        @q = ImageFile.ransack(params[:q]) # Initialize Ransack search object
        image_files = @q.result(distinct: true).order(:slide_order) # Add ordering by caption

        @pagy, @image_files = pagy(image_files, limit: params[:limit] || 100)

        # Add pagination details to headers before rendering
        pagy_headers_merge(@pagy)

        render json: @image_files.as_json
      end

      def show
        if params[:id] == 'groups'
          get_groups
        else
          image_file = ImageFile.find(params[:id])

          render json: image_file
        end
      end

      def create
        begin
          image = ImageFile.new(image_params)

          image.save!

          render json: image, status: :created
        rescue => e
          render json: e.message, status: :unprocessable_entity
        end
      end

      def update
        return unless @image_file.present?

        begin
          @image_file.update!(image_params)

          render json: { error: "" }, status: :ok
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      def destroy
        return unless @image_file.present?

        begin
          @image_file.destroy!

          render json: { error: "" }, status: :ok
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      def get_group(group)
        render json: ImageFile.where(group: group).maximum(:slide_order)
      end

      def get_groups
        render json: ImageFile.where.not(group: nil).group(:group).maximum(:slide_order)
      end

      private

      def set_image
        @image_file = nil

        return unless params[:id].present?

        begin
          @image_file = ImageFile.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: "ImageFile Collection: #{params[:id]} not found" }, status: :not_found
        end
      end

      def image_params
        params.require(:image_file).permit(:name, :caption, :description, :mime_type, :image_file)
      end
    end
  end
end
