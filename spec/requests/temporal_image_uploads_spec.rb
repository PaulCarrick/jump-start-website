require 'rails_helper'
RSpec.describe 'Temporal draft image uploads', type: :request do
  it 'saves an uploaded draft image' do
    create(:site_setup)
    sign_in create(:user, access: 'super')
    post admin_image_files_path, params: { image_file: {
      name: 'Draft upload', image: fixture_file_upload('sample.jpg', 'image/jpeg'), mime_type: 'image/jpeg'
    } }
    expect(ImageFile.count).to eq(1)
    image = ImageFile.first
    expect(image).to be_draft
    expect(image.image).to be_attached
    expect(ActiveStorage::Attachment.where(blob_id: image.attachment_blob_id)).to exist
    PublishingContext.live = true
    expect(ImageFile.find_by(id: image.id)).to be_nil
  end
end
