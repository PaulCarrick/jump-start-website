require 'rails_helper'

RSpec.describe ColumnsController, section: :controller do
  include_context "debug setup"

  let!(:section1) { create(:section, content_type: "type1", section_order: 1, description: "<b>Description 1</b>", section_name: "section1") }
  let!(:section2) { create(:section, content_type: "type1", section_order: 2, description: "<i>Description 2</i>", section_name: "section2") }
  let!(:section3) { create(:section, content_type: "type2", section_order: 1, description: "<u>Description 3</u>", section_name: "section3") }
  let!(:column1) { create(:column, section_name: "section1", column_order: 1, content: "<b>Content 1</b>", column_name: "column1") }
  let!(:column2) { create(:column, section_name: "section1", column_order: 2, content: "<i>Content 2</i>", column_name: "column2") }
  let!(:column3) { create(:column, section_name: "section2", column_order: 1, content: "<u>Content 3</u>", column_name: "column3") }

  describe "GET #index" do
    context "with valid params" do
      it "assigns the Ransack search object" do
        get :index, params: { q: { column_name_cont: "column" } }

        expect(assigns(:q)).to be_a(Ransack::Search)
        expect(assigns(:q).conditions[0].attributes[0].name).to eq("column_name")
      end

      it "paginates the results" do
        get :index, params: { q: { section_name_eq: "section1" }, section: 1, limit: 3 }
        expect(assigns(:pagy)).to be_present
        expect(assigns(:results)).to include(column1, column2)
      end

      it "filters columns based on Ransack query" do
        get :index, params: { q: { section_name_eq: "section2" } }
        expect(assigns(:results)).to include(column3)
        expect(assigns(:results)).not_to include(column1, column2)
      end
    end

    context "when no results are found" do
      before do
        Column.destroy_all
      end

      it "assigns an empty results array" do
        get :index
        expect(assigns(:results)).to be_empty
      end
    end
  end
end
