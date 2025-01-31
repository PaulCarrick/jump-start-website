require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  include_context "debug setup"

  let!(:page) { create(:page, name: "home", section: "content") }
  let!(:section) { create(:section, section_name: "main-section", content_type: "content", image: "ImageFile:sample.jpg", description: "<b>Description</b>") }
  let!(:image_file) { create(:image_file, name: "sample.jpg", caption: "Sample Caption", description: "Sample Image Description") }
  let(:missing_image_path) { ActionController::Base.helpers.image_path("missing-image.jpg") }

  describe "GET #show" do
    context "when the page exists" do
      before do
        get :show, params: { id: "home" }
      end

      it "assigns the page" do
        expect(assigns(:page)).to eq(page)
      end

      it "sets up default missing image" do
        expect(assigns(:missing_image)).to eq(missing_image_path)
      end

      it "builds contents from the page sections" do
        expect(assigns(:contents)).to be_an(Array)
        expect(assigns(:contents)).to include(section)
      end

      it "renders the show template" do
        expect(response).to render_template(:show)
      end
    end

    context "when the page does not exist" do
      before { get :show, params: { id: "non-existent-page" } }

      it "redirects to the root path with an alert" do
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Can't find page for: non-existent-page.")
      end
    end

    context "when a focused section is specified" do
      before { get :show, params: { id: "home", section_name: "main-section" } }

      it "assigns the focused section" do
        expect(assigns(:focused_section)).to eq(section)
      end
    end
  end
end
