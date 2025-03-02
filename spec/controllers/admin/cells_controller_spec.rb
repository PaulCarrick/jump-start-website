require 'rails_helper'

RSpec.describe Admin::CellsController, type: :controller do
  include_context "debug setup"

  Cell.delete_all

  let!(:admin_user) { create_admin_user }
  let(:valid_attributes) {
    {
      section_name: "Test",
      cell_name:    "Test Cell",
      content:      "<div>Test Content</div>",
      formatting:   "{ \"key\": \"value\" }"
    }
  }

  let(:invalid_attributes) {
    {
      section_name: nil,
      cell_name:    nil,
      content:      nil,
      formatting:   nil,
      image:        nil,
      link:         nil
    }
  }

  let(:new_attributes) {
    {
      section_name: "Test",
      cell_name:    "Test Cell 2",
      content:      "<div>Test Contents 2</div>",
      formatting:   "{ \"key\": \"value\" }"
    }
  }

  let!(:section) {
    create(:section,
           content_type:  "test",
           section_name:  "Test",
           section_order: 1,
           description:   "<b>Test Description</b>")
  }

  let!(:cell) { create(:cell, valid_attributes) }

  before do
    allow(controller).to receive(:controller_name).and_return("cells")
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
      expect(controller.instance_variable_get(:@default_column)).to eq('cell_order')
      expect(controller.instance_variable_get(:@has_query)).to be(true)
      expect(controller.instance_variable_get(:@has_sort)).to be(true)
      expect(controller.instance_variable_get(:@model_class)).to eq(Cell)
    end
  end

  describe "GET #new" do
    it "assigns a new instance of the model and loads section names" do
      get :new
      expect(assigns(:_cell)).to be_a_new(Cell)
      expect(assigns(:section_names)).to eq(Section.distinct.pluck(:section_name))
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new cell and redirects to index" do
        expect {
          post :create, params: { cell: new_attributes }
        }.to change(Cell, :count).by(1)

        expect(response).to redirect_to(admin_cells_path)
        expect(flash[:notice]).to eq("Cell created successfully.")
      end
    end

    context "with invalid attributes" do
      it "does not create a new cell and redirects to new" do
        expect {
          post :create, params: { cell: { cell_name: nil } }
        }.not_to change(Cell, :count)

        expect(flash[:error]).to be_present
        expect(response).to redirect_to(action: :new, turbo: false)
      end
    end
  end

  describe "GET #edit" do
    it "assigns the requested record and loads section names" do
      get :edit, params: { id: cell.id }
      expect(assigns(:_cell)).to eq(cell)
      expect(assigns(:section_names)).to eq(Cell.distinct.pluck(:section_name))
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "updates the record and redirects to index" do
        patch :update, params: { id: cell.id, cell: { cell_name: "Updated Cell" } }
        cell.reload

        expect(cell.cell_name).to eq("Updated Cell")
        expect(response).to redirect_to(admin_cells_path)
        expect(flash[:notice]).to eq("Cell updated successfully.")
      end

      it "prettifies the content before saving" do
        patch :update, params: { id: cell.id, cell: valid_attributes }
        cell.reload

        expect(cell.content).to eq("<div>Test Content</div>")
      end
    end

    context "with invalid attributes" do
      it "does not update the record and redirects to edit" do
        patch :update, params: { id: cell.id, cell: { section_name: nil } }
        expect(cell.cell_name).to eq("Test Cell")
        expect(flash[:error]).to be_present
        expect(response).to redirect_to(action: :edit, turbo: false)
      end
    end
  end
end
