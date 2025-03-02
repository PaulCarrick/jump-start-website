require 'rails_helper'

RSpec.describe Admin::PagesController, type: :controller do
  include_context "debug setup"

  Page.delete_all

  let!(:admin_user) { create_admin_user }
  let(:valid_attributes) { { name: "Test Page", title: "Test Page", section: "test" } }
  let(:invalid_attributes) { { name: nil, title: nil, section: nil } }
  let!(:page) { create(:page, valid_attributes) }
  let!(:section) {
    create(:section,
           content_type:  "test",
           section_order: 1,
           description:   "<b>Test Description</b>",
           section_name:  "section")
  }

  let!(:admin_user) { create_admin_user }
  before do
    allow(controller).to receive(:controller_name).and_return("pages")
  end

  describe "Initialization" do
    it "inherits from Admin::AbstractAdminController" do
      expect(controller).to be_a_kind_of(Admin::AbstractAdminController)
    end

    it "sets the correct default attributes" do
      get :index
      expect(controller.instance_variable_get(:@page_limit)).to eq(20)
      expect(controller.instance_variable_get(:@default_column)).to eq('name')
      expect(controller.instance_variable_get(:@has_query)).to be(false)
      expect(controller.instance_variable_get(:@has_sort)).to be(true)
      expect(controller.instance_variable_get(:@model_class)).to eq(Page)
    end
  end

  describe "GET #index" do
    it "assigns @results and paginates records" do
      get :index
      expect(assigns(:results)).to include(page)
      expect(assigns(:pagy)).to be_present
    end

    it "sorts records by the default cell" do
      get :index, params: { sort: 'name asc' }
      expect(assigns(:results).first).to eq(page)
    end
  end

  describe "GET #new" do
    it "assigns a new instance of the model" do
      get :new
      expect(assigns(:_page)).to be_a_new(Page)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new record and redirects to index" do
        expect {
          post :create, params: { page: valid_attributes }
        }.to change(Page, :count).by(1)
        expect(response).to redirect_to(action: :index, turbo: false)
        expect(flash[:notice]).to eq("Page created successfully.")
      end
    end

    context "with invalid attributes" do
      it "does not create a new record and redirects to new" do
        expect {
          post :create, params: { page: invalid_attributes }
        }.to change(ImageFile, :count).by(0)

        expect(flash[:error]).to be_present
        expect(response).to redirect_to(action: :new, turbo: false)
      end
    end
  end

  describe "GET #edit" do
    it "assigns the requested record" do
      get :edit, params: { id: page.id }
      expect(assigns(:_page)).to eq(page)
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "updates the record and redirects to index" do
        patch :update, params: { id: page.id, page: { name: "Updated Page" } }
        page.reload
        expect(page.name).to eq("Updated Page")
        expect(response).to redirect_to(action: :index, turbo: false)
        expect(flash[:notice]).to eq("Page updated successfully.")
      end
    end

    context "with invalid attributes" do
      it "does not update the record and redirects to edit" do
        patch :update, params: { id: page.id, page: invalid_attributes }
        expect(page.name).to eq("Test Page")
        expect(flash[:error]).to be_present
        expect(response).to redirect_to(action: :edit, turbo: false)
      end
    end
  end

  describe "GET #show" do
    it "assigns the requested record" do
      get :show, params: { id: page.id }
      expect(assigns(:_page)).to eq(page)
    end
  end

  describe "DELETE #destroy" do
    it "destroys the record and redirects to index" do
      expect {
        delete :destroy, params: { id: page.id }
      }.to change(Page, :count).by(-1)

      expect(response).to redirect_to(action: :index, turbo: false)
      expect(flash[:notice]).to eq("Page deleted successfully.")
    end
  end
end
