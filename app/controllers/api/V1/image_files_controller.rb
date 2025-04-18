# frozen_string_literal: true

# app/controllers/api/v1/image_files_controller.rb
module Api
  module V1
    # noinspection RailsParamDefResolve
    class ImageFilesController < ApplicationController
      include Pagy::Backend # Include Pagy for pagination

      before_action :set_image, only: %i[ update destroy ]

      def index
        @q          = ImageFile.ransack(params[:q]) # Initialize Ransack search object
        image_files = @q.result(distinct: true).order(:slide_order) # Add ordering by caption

        @pagy, @image_files = pagy(image_files, limit: params[:limit] || 100)

        # Add pagination details to headers before rendering
        pagy_headers_merge(@pagy)

        render json: @image_files.as_json
      end

      def show
        if params[:id].kind_of?(String)
          image_file = ImageFile.find_by(name: params[:id])
        else
          image_file = ImageFile.find(params[:id])
        end

        render json: image_file
      end

      def create
        begin
          debugger
          image = ImageFile.new(image_params)

          if params[:image_file][:image].present?
            image.image.attach(params[:image_file][:image])
            unless image.image.attached?
              return render json: { error: "Failed to attach image" }, status: :unprocessable_entity
            end
          end

          image.save!

          render json: image, status: :created
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      def update
        return unless @image_file.present?

        begin
          if params[:image_file][:image].present?
            @image_file.image.purge if @image_file.image.attached?
            @image_file.image.attach(params[:image_file][:image])
          end

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

      def get_group
        group_param = params[:group] # Ensure group is passed in params

        return render json: { error: "Group parameter is required" }, status: :bad_request unless group_param.present?

        max_slide_order = ImageFile.where(group: group_param).maximum(:slide_order)

        render json: { max_slide_order: max_slide_order }
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
        params.require(:image_file).permit(:name, :caption, :description, :mime_type, :image) # Change image_file -> image
      end
    end
  end
end
