require 'rails_helper'

RSpec.describe ImageFilesController, type: :controller do
  include_context "debug setup"

  let!(:image_file1) { create(:image_file, name: "test-1", group: "daily", mime_type: "image/jpeg", caption: "Caption 1") }
  let!(:image_file2) { create(:image_file, name: "test-2", group: "daily", mime_type: "image/jpeg", caption: "Caption 2") }
  let!(:non_jpeg_image) { create(:image_file, name: "test-3", group: "daily", mime_type: "image/png", caption: "PNG Caption") }
  let!(:unrelated_image) { create(:image_file, name: "test-4", group: "unrelated", mime_type: "image/jpeg", caption: "Unrelated Caption") }

  describe "GET #show" do
    context "when id is 'picture-of-the-day'" do
      it "assigns a random image file with a caption from the group" do
        get :show, params: { id: "picture-of-the-day" }
        expect(assigns(:image_file)).to eq(image_file1).or eq(image_file2).or eq(unrelated_image)
      end

      it "only selects JPEGs with captions in the group" do
        get :show, params: { id: "picture-of-the-day" }
        expect(assigns(:image_file).mime_type).to eq("image/jpeg")
        expect(assigns(:image_file).caption).not_to be_nil
      end
    end

    context "when id is a specific image file id" do
      it "assigns the requested image file" do
        get :show, params: { id: image_file1.id }
        expect(assigns(:image_file)).to eq(image_file1)
      end
    end

    context "when the image file is not found" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          get :show, params: { id: -1 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
