require 'rails_helper'

RSpec.describe "Image file URLs", type: :request do
  let!(:image_file) { create(:image_file, name: "Port-safe image") }

  before { host! "localhost:3100" }

  it "serves image bytes on the same host and port as the page" do
    get image_file_path(image_file)
    expect(response).to be_successful

    image = Nokogiri::HTML(response.body).at_css('img[alt="Port-safe image"]')
    expect(image).to be_present
    expect(image['src']).to start_with('/rails/active_storage/')

    get image['src']
    expect(response).to have_http_status(:redirect)
    expect(URI.parse(response.location).host).to eq("localhost")
    expect(URI.parse(response.location).port).to eq(3100)

    follow_redirect!
    expect(response).to be_successful
    expect(response.media_type).to eq("image/jpeg")
    expect(response.body.bytesize).to be_positive
  end

  it "returns relative image paths from the image API" do
    get api_v1_image_files_path, params: { q: { name_eq: image_file.name } }
    expect(response).to be_successful
    expect(response.parsed_body.first['image_url']).to eq(image_file.image_url)
    expect(response.parsed_body.first['image_url']).to start_with('/rails/active_storage/')
  end
end
