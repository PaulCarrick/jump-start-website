class ImageFileSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name, :mime_type, :caption, :description, :image_url

  def image_url
    rails_blob_url(object.image, only_path: true) if object.image.attached?
  end
end
