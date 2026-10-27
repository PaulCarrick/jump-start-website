require "rails_helper"

RSpec.describe "Public image URLs", type: :request do
  it "serves attached images on the request host and port" do
    image = ImageFile.new(name: "Port independent image", mime_type: "image/png")
    image.image.attach(io: StringIO.new("image bytes"), filename: "image.png", content_type: "image/png")
    image.save!

    host! "localhost:3001"
    get "/api/v1/image_files"
    expect(response).to have_http_status(:ok)
    image_url = response.parsed_body.find { |item| item["id"] == image.id }.fetch("image_url")
    expect(image_url).to start_with("/rails/active_storage/blobs/redirect/")

    get image_url
    expect(response).to have_http_status(:redirect)
    expect(URI.parse(response.location).host).to eq("localhost")
    expect(URI.parse(response.location).port).to eq(3001)
    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(response.body).to eq("image bytes")
  end
end
