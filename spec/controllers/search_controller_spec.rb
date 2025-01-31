require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  include_context "debug setup"

  let!(:section) { create(:section, section_name: "main-section", content_type: "content", image: "ImageFile:sample.jpg", description: "<b>Description</b>") }

  describe "GET #new" do
    context "without query parameters" do
      it "initializes a new Ransack search object" do
        get :new
        expect(assigns(:q)).to be_a(Ransack::Search)
        expect(assigns(:q).result.first.id).to eq(section.id)
      end

      it "renders the new template" do
        get :new
        expect(response).to render_template(:new)
      end

      it "returns a 200 HTTP status" do
        get :new
        expect(response).to have_http_status(:ok)
      end
    end

    context "with query parameters" do
      let(:query_params) { { q: { section_name_cont: "test" } } }

      it "initializes a Ransack search object with the provided query" do
        get :new, params: query_params
        expect(assigns(:q)).to be_a(Ransack::Search)
        expect(assigns(:q).conditions[0].attributes[0].name).to eq("section_name")
      end

      it "renders the new template" do
        get :new, params: query_params
        expect(response).to render_template(:new)
      end
    end

    context "when no sections are present" do
      it "still initializes a Ransack search object" do
        Section.destroy_all
        get :new
        expect(assigns(:q)).to be_a(Ransack::Search)
      end
    end
  end
end
