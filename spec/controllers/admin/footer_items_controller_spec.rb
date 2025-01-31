require 'rails_helper'

RSpec.describe Admin::FooterItemsController, type: :controller do
  FooterItem.delete_all

  let!(:admin_user) { create_admin_user }
  include_context "debug setup"

  let(:valid_attributes) {
    {
      label:        "Test Footer Item",
      icon:         nil,
      link:         "/test-url",
      options:      "",
      access:       "",
      footer_order: 1,
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
      footer_order: nil,
      parent_id:    nil
    }
  }
  let!(:footer_item) { create(:footer_item, valid_attributes) }

  before do
    allow(controller).to receive(:controller_name).and_return("footer_items")
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
      expect(controller.instance_variable_get(:@model_class)).to eq(FooterItem)
    end
  end

  describe "GET #index" do
    it "assigns @results and paginates records" do
      get :index
      expect(assigns(:results)).to include(footer_item)
      expect(assigns(:pagy)).to be_present
    end

    it "sorts records by the default column" do
      get :index, params: { sort: 'label asc' }
      expect(assigns(:results).first).to eq(footer_item)
    end
  end

  describe "GET #new" do
    it "assigns a new instance of the model" do
      get :new
      expect(assigns(:_footer_item)).to be_a_new(FooterItem)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new record and redirects to index" do
        expect {
          post :create, params: { footer_item: valid_attributes }
        }.to change(FooterItem, :count).by(1)

        expect(response).to redirect_to(action: :index, turbo: false)
        expect(flash[:notice]).to eq("Footer Item created successfully.")
      end
    end

    context "with invalid attributes" do
      it "does not create a new record and redirects to new" do
        expect {
          post :create, params: { footer_item: invalid_attributes }
        }.not_to change(FooterItem, :count)

        expect(flash[:error]).to be_present
        expect(response).to redirect_to(action: :new, turbo: false)
      end
    end
  end

  describe "GET #edit" do
    it "assigns the requested record" do
      get :edit, params: { id: footer_item.id }
      expect(assigns(:_footer_item)).to eq(footer_item)
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "updates the record and redirects to index" do
        patch :update, params: { id: footer_item.id, footer_item: { label: "Updated Footer Item" } }
        footer_item.reload
        expect(footer_item.label).to eq("Updated Footer Item")
        expect(response).to redirect_to(action: :index, turbo: false)
        expect(flash[:notice]).to eq("Footer Item updated successfully.")
      end
    end

    context "with invalid attributes" do
      it "does not update the record and redirects to edit" do
        patch :update, params: { id: footer_item.id, footer_item: invalid_attributes }
        expect(footer_item.label).to eq("Test Footer Item")
        expect(flash[:error]).to be_present
        expect(response).to redirect_to(action: :edit, turbo: false)
      end
    end
  end

  describe "GET #show" do
    it "assigns the requested record" do
      get :show, params: { id: footer_item.id }
      expect(assigns(:_footer_item)).to eq(footer_item)
    end
  end

  describe "DELETE #destroy" do
    it "destroys the record and redirects to index" do
      expect {
        delete :destroy, params: { id: footer_item.id }
      }.to change(FooterItem, :count).by(-1)

      expect(response).to redirect_to(action: :index, turbo: false)
      expect(flash[:notice]).to eq("Footer Item deleted successfully.")
    end
  end
end
