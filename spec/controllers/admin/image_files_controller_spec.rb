require 'rails_helper'

RSpec.describe Admin::ImageFilesController, type: :controller do
  include_context "debug setup"

  ImageFile.delete_all

  let!(:admin_user) { create_admin_user }
  let(:valid_attributes) {
    {
      name:        "Test Image",
      caption:     "Test Caption",
      mime_type:   "image/jpeg",
      group:       "Test Group",
      slide_order: 1,
      image:       Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/sample.jpg'), 'image/jpeg')
    }
  }
  let(:invalid_attributes) {
    {
      name:        nil,
      caption:     nil,
      mime_type:   nil,
      group:       nil,
      slide_order: nil
    }
  }
  let!(:image_file) { create(:image_file, valid_attributes) }

  before do
    allow(controller).to receive(:controller_name).and_return("image_files")
  end

  describe "Initialization" do
    it "inherits from Admin::AbstractAdminController" do
      expect(controller).to be_a_kind_of(Admin::AbstractAdminController)
    end

    it "sets the correct default attributes" do
      get :index
      expect(controller.instance_variable_get(:@page_limit)).to eq(4)
      expect(controller.instance_variable_get(:@default_column)).to eq('id')
      expect(controller.instance_variable_get(:@has_query)).to be(true)
      expect(controller.instance_variable_get(:@has_sort)).to be(true)
      expect(controller.instance_variable_get(:@model_class)).to eq(ImageFile)
      expect(controller.instance_variable_get(:@fields)).to include(:image, :name, :caption, :mime_type, :group, :slide_order)
    end
  end

  describe "GET #index" do
    it "assigns @results and paginates records" do
      get :index
      expect(assigns(:results)).to include(image_file)
      expect(assigns(:pagy)).to be_present
    end

    it "filters records using Ransack queries" do
      get :index, params: { q: { name_cont: "Test" } }
      expect(assigns(:results)).to include(image_file)
    end

    it "sorts records by the default column" do
      get :index, params: { sort: 'name asc' }
      expect(assigns(:results).first).to eq(image_file)
    end
  end

  describe "GET #new" do
    it "assigns a new instance of the model" do
      get :new
      expect(assigns(:_image_file)).to be_a_new(ImageFile)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new record and redirects to index" do
        expect {
          post :create,
               params: {
                 image_file:
                   {
                     name:        "Test Image - #{Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)}",
                     caption:     "Test Caption",
                     mime_type:   "image/jpeg",
                     group:       "Test Group",
                     slide_order: 1,
                     image:       Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/sample.jpg'), 'image/jpeg')
                   }
               }
        }.to change(ImageFile, :count).by(1)

        expect(response).to redirect_to(action: :index, turbo: false)
        expect(flash[:notice]).to eq("Image File created successfully.")
      end
    end

    context "with invalid attributes" do
      it "does not create a new record and redirects to new" do
        expect {
          post :create, params: { image_file: invalid_attributes }
        }.not_to change(ImageFile, :count)

        expect(flash[:error]).to be_present
        expect(response).to redirect_to(action: :new, turbo: false)
      end
    end
  end

  describe "GET #edit" do
    it "assigns the requested record" do
      get :edit, params: { id: image_file.id }
      expect(assigns(:_image_file)).to eq(image_file)
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "updates the record and redirects to index" do
        patch :update, params: { id: image_file.id, image_file: { name: "Updated Image" } }
        image_file.reload
        expect(image_file.name).to eq("Updated Image")
        expect(response).to redirect_to(action: :index, turbo: false)
        expect(flash[:notice]).to eq("Image File updated successfully.")
      end
    end

    context "with invalid attributes" do
      it "does not update the record and redirects to edit" do
        patch :update, params: { id: image_file.id, image_file: invalid_attributes }
        expect(image_file.name).to eq("Test Image")
        expect(flash[:error]).to be_present
        expect(response).to redirect_to(action: :edit, turbo: false)
      end
    end
  end

  describe "GET #show" do
    it "assigns the requested record" do
      get :show, params: { id: image_file.id }
      expect(assigns(:_image_file)).to eq(image_file)
    end
  end

  describe "DELETE #destroy" do
    it "destroys the record and redirects to index" do
      expect {
        delete :destroy, params: { id: image_file.id }
      }.to change(ImageFile, :count).by(-1)

      expect(response).to redirect_to(action: :index, turbo: false)
      expect(flash[:notice]).to eq("Image File deleted successfully.")
    end
  end
end
