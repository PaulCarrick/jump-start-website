require 'rails_helper'

RSpec.describe 'Picture of the Day', type: :request do
  let!(:setup) { SiteSetup.find_by(configuration_name: 'default') || create(:site_setup) }

  it 'shows the picture with rounded corners' do
    create(:image_file, name: 'rose', caption: '<p>A rose</p>', mime_type: 'image/jpeg')
    get '/image_files/picture-of-the-day'
    expect(response).to have_http_status(:ok)
    image = Nokogiri::HTML(response.body).at('img[alt="rose"]')
    expect(image['class']).to include('rounded-3')
  end
end
