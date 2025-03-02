require 'rails_helper'

RSpec.describe Admin::MenuItemsController, type: :controller do
  include_context "debug setup"

  MenuItem.delete_all

  let!(:admin_user) { create_admin_user }
  let(:valid_attributes) {
    {
      label:        "Test Menu Item",
      icon:         nil,
      link:         "/test-url",
      options:      "",
      access:       "",
      menu_order: 1,
      parent_id:    nil
    }
  }
  let(:invalid_attributes) {
    {
      label:        nil,
      icon:         nil,
      link:         nil,
      options:      nil,
      access:       nil,
      menu_order: nil,
      parent_id:    nil
    }
  }
  let!(:menu_item) { create(:menu_item, valid_attributes) }

  before do
    allow(controller).to receive(:controller_name).and_return("menu_items")
  end

  describe "Initialization" do
    it "inherits from Admin::AbstractAdminController" do
      expect(controller).to be_a_kind_of(Admin::AbstractAdminController)
    end

    it "sets the correct default attributes" do
      get :index
      expect(controller.instance_variable_get(:@page_limit)).to eq(20)
      expect(controller.instance_variable_get(:@default_column)).to eq('label')
      expect(controller.instance_variable_get(:@has_query)).to be(false)
      expect(controller.instance_variable_get(:@has_sort)).to be(true)
      expect(controller.instance_variable_get(:@model_class)).to eq(MenuItem)
    end
  end

  describe "GET #index" do
    it "assigns @results and paginates records" do
      get :index
      expect(assigns(:results)).to include(menu_item)
      expect(assigns(:pagy)).to be_present
    end

    it "sorts records by the default cell" do
      get :index, params: { sort: 'label asc' }
      expect(assigns(:results).first).to eq(menu_item)
    end
  end

  describe "GET #new" do
    it "assigns a new instance of the model" do
      get :new
      expect(assigns(:_menu_item)).to be_a_new(MenuItem)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new record and redirects to index" do
        expect {
          post :create, params: { menu_item: valid_attributes }
        }.to change(MenuItem, :count).by(1)

        expect(response).to redirect_to(action: :index, turbo: false)
        expect(flash[:notice]).to eq("Menu Item created successfully.")
      end
    end

    context "with invalid attributes" do
      it "does not create a new record and redirects to new" do
        expect {
          post :create, params: { menu_item: invalid_attributes }
        }.not_to change(MenuItem, :count)

        expect(flash[:error]).to be_present
        expect(response).to redirect_to(action: :new, turbo: false)
      end
    end
  end

  describe "GET #edit" do
    it "assigns the requested record" do
      get :edit, params: { id: menu_item.id }
      expect(assigns(:_menu_item)).to eq(menu_item)
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "updates the record and redirects to index" do
        patch :update, params: { id: menu_item.id, menu_item: { label: "Updated Menu Item" } }
        menu_item.reload
        expect(menu_item.label).to eq("Updated Menu Item")
        expect(response).to redirect_to(action: :index, turbo: false)
        expect(flash[:notice]).to eq("Menu Item updated successfully.")
      end
    end

    context "with invalid attributes" do
      it "does not update the record and redirects to edit" do
        patch :update, params: { id: menu_item.id, menu_item: invalid_attributes }
        expect(menu_item.label).to eq("Test Menu Item")
        expect(flash[:error]).to be_present
        expect(response).to redirect_to(action: :edit, turbo: false)
      end
    end
  end

  describe "GET #show" do
    it "assigns the requested record" do
      get :show, params: { id: menu_item.id }
      expect(assigns(:_menu_item)).to eq(menu_item)
    end
  end

  describe "DELETE #destroy" do
    it "destroys the record and redirects to index" do
      expect {
        delete :destroy, params: { id: menu_item.id }
      }.to change(MenuItem, :count).by(-1)

      expect(response).to redirect_to(action: :index, turbo: false)
      expect(flash[:notice]).to eq("Menu Item deleted successfully.")
    end
  end
end
