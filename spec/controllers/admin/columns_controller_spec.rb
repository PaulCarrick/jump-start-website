require 'rails_helper'

RSpec.describe Admin::ColumnsController, type: :controller do
  include_context "debug setup"

  Column.delete_all

  let!(:admin_user) { create_admin_user }
  let(:valid_attributes) {
    {
      section_name: "Test",
      column_name:  "Test Column",
      content:      "<div>Test Content</div>",
      formatting:   "{ \"key\": \"value\" }"
    }
  }

  let(:invalid_attributes) {
    {
      section_name: nil,
      column_name:  nil,
      content:      nil,
      formatting:   nil,
      image:        nil,
      link:         nil
    }
  }

  let(:new_attributes) {
    {
      section_name: "Test",
      column_name:  "Test Column 2",
      content:      "<div>Test Contents 2</div>",
      formatting:   "{ \"key\": \"value\" }"
    }
  }

  let!(:column) { create(:column, valid_attributes) }

  before do
    allow(controller).to receive(:controller_name).and_return("columns")
    allow(Utilities).to receive(:pretty_print_html).and_return("<div>\n  Test Content\n</div>")
    allow(Utilities).to receive(:pretty_print_json).and_return("{\n  \"key\": \"value\"\n}")
  end

  describe "Initialization" do
    it "inherits from Admin::AbstractAdminController" do
      expect(controller).to be_a_kind_of(Admin::AbstractAdminController)
    end

    it "sets the correct default attributes" do
      get :index
      expect(controller.instance_variable_get(:@page_limit)).to eq(1)
      expect(controller.instance_variable_get(:@default_column)).to eq('column_order')
      expect(controller.instance_variable_get(:@has_query)).to be(true)
      expect(controller.instance_variable_get(:@has_sort)).to be(true)
      expect(controller.instance_variable_get(:@model_class)).to eq(Column)
    end
  end

  describe "GET #new" do
    it "assigns a new instance of the model and loads section names" do
      get :new
      expect(assigns(:_column)).to be_a_new(Column)
      expect(assigns(:section_names)).to eq(Column.distinct.pluck(:section_name))
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new column and redirects to index" do
        expect {
          post :create, params: { column: new_attributes }
        }.to change(Column, :count).by(1)

        expect(response).to redirect_to(admin_columns_path)
        expect(flash[:notice]).to eq("Column created successfully.")
      end
    end

    context "with invalid attributes" do
      it "does not create a new column and redirects to new" do
        expect {
          post :create, params: { column: invalid_attributes }
        }.not_to change(Column, :count)

        expect(flash[:error]).to be_present
        expect(response).to redirect_to(action: :new, turbo: false)
      end
    end
  end

  describe "GET #edit" do
    it "assigns the requested record and loads section names" do
      get :edit, params: { id: column.id }
      expect(assigns(:_column)).to eq(column)
      expect(assigns(:section_names)).to eq(Column.distinct.pluck(:section_name))
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "updates the record and redirects to index" do
        patch :update, params: { id: column.id, column: { column_name: "Updated Column" } }
        column.reload

        expect(column.column_name).to eq("Updated Column")
        expect(response).to redirect_to(admin_columns_path)
        expect(flash[:notice]).to eq("Column updated successfully.")
      end

      it "prettifies the content before saving" do
        patch :update, params: { id: column.id, column: valid_attributes }
        column.reload

        expect(column.content).to eq("<div>Test Content</div>")
      end
    end

    context "with invalid attributes" do
      it "does not update the record and redirects to edit" do
        patch :update, params: { id: column.id, column: invalid_attributes }
        expect(column.column_name).to eq("Test Column")
        expect(flash[:error]).to be_present
        expect(response).to redirect_to(action: :edit, turbo: false)
      end
    end
  end
end
