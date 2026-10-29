require 'rails_helper'

RSpec.describe SectionController, type: :controller do
  include_context "debug setup"

  let!(:page1) { create(:page, name: "page1", title: "Page 1", section: "type1") }
  let!(:page2) { create(:page, name: "page2", title: "Page 2", section: "type2") }
  let!(:section1) { create(:section, page: page1, content_type: "type1", section_order: 1, description: "<b>Description 1</b>", section_name: "section1") }
  let!(:section2) { create(:section, page: page1, content_type: "type1", section_order: 2, description: "<i>Description 2</i>", section_name: "section2") }
  let!(:section3) { create(:section, page: page2, content_type: "type2", section_order: 1, description: "<u>Description 3</u>", section_name: "section3") }

  describe "GET #index" do
    context "with valid params" do
      it "assigns the Ransack search object" do
        get :index, params: { q: { section_name_cont: "section" } }
        expect(assigns(:q)).to be_a(Ransack::Search)
        expect(assigns(:q).conditions[0].attributes[0].name).to eq("section_name")
      end

      it "paginates the results" do
        get :index, params: { q: { content_type_eq: "type1" }, page: 1, limit: 3 }
        expect(assigns(:pagy)).to be_present
        expect(assigns(:results)).to include(section1, section2)
      end

      it "filters sections based on Ransack query" do
        get :index, params: { q: { content_type_eq: "type2" } }
        expect(assigns(:results)).to include(section3)
        expect(assigns(:results)).not_to include(section1, section2)
      end
    end

    context "processing sections into rows" do
      it "builds rows for valid sections" do
        get :index
        rows = assigns(:sections)

        expect(rows).to be_an(Array)
        expect(rows.size).to eq(3)
        expect(rows).to contain_exactly(
          { title: "Page 1", description: "<b>Description 1</b>",
            url: page_path("page1", section_name: "section1"), index: 0 },
          { title: "Page 1", description: "<i>Description 2</i>",
            url: page_path("page1", section_name: "section2"), index: 0 },
          { title: "Page 2", description: "Description 3",
            url: page_path("page2", section_name: "section3"), index: 0 }
        )
      end
    end

    context "when no results are found" do
      before do
        Section.destroy_all
      end

      it "assigns an empty results array" do
        get :index
        expect(assigns(:results)).to be_empty
      end

      it "assigns an empty sections array" do
        get :index
        expect(assigns(:sections)).to be_empty
      end
    end
  end
end
