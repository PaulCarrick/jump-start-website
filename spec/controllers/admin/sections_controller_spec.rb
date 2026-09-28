require 'rails_helper'

RSpec.describe Admin::SectionsController, type: :controller do
  include_context "debug setup"

  # destroy_all (not delete_all) so it cascades to dependent Cells via
  # Section's has_many :cells, dependent: :destroy - a raw delete_all would
  # violate cells.section_id's foreign key if any Cell still references one
  # of these sections.
  Section.destroy_all

  let!(:admin_user) { create_admin_user }
  let(:valid_attributes) {
    {
      content_type: "Test Content Type",
      section_name: "Test Section",
      description:  "<div>Test Description</div>",
      formatting:   "{ \"key\": \"value\" }"
    }
  }

  let(:invalid_attributes) {
    {
      content_type: nil,
      section_name: nil,
      description:  nil,
      formatting:   nil,
      image:        nil,
      link:         nil
    }
  }

  let!(:section) { create(:section, valid_attributes) }

  before do
    allow(controller).to receive(:controller_name).and_return("sections")
    allow(Utilities).to receive(:pretty_print_html).and_return("<div>\n  Test Description\n</div>")
    allow(Utilities).to receive(:pretty_print_json).and_return("{\n  \"key\": \"value\"\n}")
  end

  describe "Initialization" do
    it "inherits from Admin::AbstractAdminController" do
      expect(controller).to be_a_kind_of(Admin::AbstractAdminController)
    end

    it "sets the correct default attributes" do
      get :index
      expect(controller.instance_variable_get(:@page_limit)).to eq(1)
      expect(controller.instance_variable_get(:@default_column)).to eq('id')
      expect(controller.instance_variable_get(:@has_query)).to be(true)
      expect(controller.instance_variable_get(:@has_sort)).to be(true)
      expect(controller.instance_variable_get(:@model_class)).to eq(Section)
    end
  end

  # GET #new / POST #create were removed along with the standalone
  # /admin/sections/new form - sections are only ever created in the context
  # of a page now, via Admin::PagesController#add_section_to_page.

  describe "GET #edit" do
    it "assigns the requested record and loads content types" do
      get :edit, params: { id: section.id }
      expect(assigns(:_section)).to eq(section)
      expect(assigns(:content_types)).to eq(Section.distinct.pluck(:content_type))
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "updates the record and redirects to index" do
        patch :update, params: { id: section.id, section: { section_name: "Updated Section" } }
        section.reload

        expect(section.section_name).to eq("Updated Section")
        expect(response).to redirect_to(admin_sections_path)
        expect(flash[:notice]).to eq("Section updated successfully.")
      end

      it "prettifies the description before saving" do
        patch :update, params: { id: section.id, section: valid_attributes }
        section.reload

        expect(section.description).to eq("<div>Test Description</div>")
      end
    end

    context "with invalid attributes" do
      it "does not update the record and redirects to edit" do
        patch :update, params: { id: section.id, section: invalid_attributes }
        expect(section.section_name).to eq("Test Section")
        expect(flash[:error]).to be_present
        expect(response).to redirect_to(action: :edit, turbo: false)
      end
    end
  end
end
