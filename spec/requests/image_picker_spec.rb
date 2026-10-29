require 'rails_helper'

RSpec.describe 'Image picker catalog and return', type: :request do
  it 'requires login for catalog refresh and dialog completion' do
    get admin_image_files_path(image_picker_choices: true)
    expect(response).to redirect_to(new_user_session_path)
    get admin_image_files_path(image_picker_complete: true)
    expect(response).to redirect_to(new_user_session_path)
  end

  it 'returns the complete sorted catalog, including new groups and videos' do
    sign_in create(:user, access: 'super')
    create_list(:image_file, 6, group: 'New group')
    video = create(:image_file, name: 'Movie', mime_type: 'video/mp4', group: nil)
    get admin_image_files_path(image_picker_choices: true)
    expect(response).to have_http_status(:ok)
    catalog = response.parsed_body
    expect(catalog['images'].length).to eq(6)
    expect(catalog['images']).to eq(catalog['images'].sort)
    expect(catalog['videos']).to eq([ video.name ])
    expect(catalog['groups']).to eq([ 'New group' ])
  end

  it 'preserves the dialog return destination after a validation failure' do
    sign_in create(:user, access: 'super')
    target = admin_image_files_path(image_picker_complete: true)
    expect {
      post admin_image_files_path, params: { return_url: target, image_file: { name: 'Missing file' } }
    }.not_to change(ImageFile, :count)
    follow_redirect!
    expect(Nokogiri::HTML(response.body).text).to include("Image can't be blank")
    expect(Nokogiri::HTML(response.body).at_css('input[name="return_url"]')['value']).to eq(target)
  end
end
