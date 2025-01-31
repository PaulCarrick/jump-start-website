# frozen_string_literal: true

# app/controllers/image_files_controller.rb
class ImageFilesController < ApplicationController
  def show
    if params[:id] == "picture-of-the-day"
      image_files = ImageFile.jpegs_with_captions_in_an_image_group
      pod_number  = session[:pod_number]

      unless pod_number.present?
        pod_number           = rand(image_files.length)
        session[:pod_number] = pod_number
      end

      @image_file = image_files[pod_number]

      render "picture_of_the_day"

      nil
    else
      set_image
    end
  end

  private

  def set_image
    @image_file = ImageFile.find(params[:id])
  end

  def image_params
    params.require(:image_file).permit(:name, :group, :slide_order, :mime_type, :caption, :description, :image)
  end
end
