require 'rails_helper'

RSpec.describe 'Media library', type: :request do
  let!(:setup) { create(:site_setup) }
  let(:admin) { create(:user, access: 'super') }

  def upload_file(name, type)
    Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files', name), type)
  end

  before { sign_in admin }

  describe 'uploading several files at once' do
    it 'creates one image per file, named after the file' do
      expect do
        post admin_upload_image_files_path, params: {
          files: [ upload_file('sample.jpg', 'image/jpeg'), upload_file('lori.jpg', 'image/jpeg') ]
        }
      end.to change(ImageFile, :count).by(2)

      expect(response).to redirect_to(%r{/admin/image_files})
      expect(flash[:notice]).to eq('Uploaded 2 files.')
      image = ImageFile.find_by!(name: 'lori')
      expect(image.mime_type).to eq('image/jpeg')
      expect(image.image).to be_attached
    end

    it 'never reuses a name that pages may already refer to' do
      create(:image_file, name: 'sample')
      post admin_upload_image_files_path, params: { files: [ upload_file('sample.jpg', 'image/jpeg') ] }
      expect(ImageFile.where(name: 'sample-2')).to exist
      expect(response).to redirect_to(%r{selected=#{ImageFile.find_by!(name: 'sample-2').id}})
    end

    it 'adds the files to the end of a group' do
      create(:image_file, name: 'existing', group: 'garden', slide_order: 4)
      post admin_upload_image_files_path, params: {
        group: 'garden', files: [ upload_file('sample.jpg', 'image/jpeg'), upload_file('lori.jpg', 'image/jpeg') ]
      }
      expect(ImageFile.where(group: 'garden').order(:slide_order).pluck(:name, :slide_order))
        .to eq([ [ 'existing', 4 ], [ 'sample', 5 ], [ 'lori', 6 ] ])
      expect(flash[:notice]).to eq('Uploaded 2 files to the group garden.')
    end

    it 'skips files that are not images or MP4 videos, whatever they claim to be' do
      text = Tempfile.new([ 'notes', '.txt' ])
      text.write('plain text, not a picture')
      text.rewind
      expect do
        post admin_upload_image_files_path, params: {
          files: [ Rack::Test::UploadedFile.new(text.path, 'image/jpeg'), upload_file('introduction-to-pact.mp4', 'video/mp4') ]
        }
      end.to change(ImageFile, :count).by(1)
      expect(ImageFile.find_by!(name: 'introduction-to-pact').mime_type).to eq('video/mp4')
      expect(flash[:error]).to include('not an image or MP4 video')
    ensure
      text&.close!
    end

    it 'asks for files when none are sent' do
      post admin_upload_image_files_path
      expect(flash[:error]).to eq('Choose one or more files to upload.')
    end

    it 'is only for administrators' do
      sign_in create(:user, access: 'read_only')
      expect do
        post admin_upload_image_files_path, params: { files: [ upload_file('sample.jpg', 'image/jpeg') ] }
      end.not_to change(ImageFile, :count)
    end
  end

  describe 'the details panel' do
    let!(:image) { create(:image_file, name: 'rose', group: 'garden') }
    let!(:page_record) { create(:page, name: 'flowers', title: 'Flowers') }

    it 'lists the pages that show the image, as a picture or in a slide show' do
      section = create(:section, page: page_record, content_type: page_record.section, image: 'ImageGroup:garden')
      create(:cell, section: section, image: 'ImageFile: rose')
      get admin_image_files_path(selected: image.id)

      expect(response).to have_http_status(:ok)
      usage = Nokogiri::HTML(response.body).css('.admin-media-usage li').map { |item| item.text.squish }
      expect(usage).to eq([ 'Flowers · Picture, Slide show (group garden)' ])
    end

    it 'does not count an image whose name only starts the same' do
      section = create(:section, page: page_record, content_type: page_record.section, image: nil)
      create(:cell, section: section, image: 'ImageFile:roses')
      get admin_image_files_path(selected: image.id)
      expect(response.body).to include('Not used on any page.')
    end

    it 'filters the grid by group' do
      create(:image_file, name: 'tulip', group: 'other')
      get admin_image_files_path('q[group_eq]' => 'garden')
      names = Nokogiri::HTML(response.body).css('.admin-media-name').map(&:text)
      expect(names).to include('rose')
      expect(names).not_to include('tulip')
    end
  end
end
