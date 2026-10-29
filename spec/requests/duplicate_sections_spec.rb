require "rails_helper"

RSpec.describe "Duplicate a page section", type: :request do
  let!(:section) { create(:section, section_name: "Details") }
  let!(:cell) { create(:cell, section: section) }
  let(:path) { admin_duplicate_page_section_path(page_id: section.page_id, id: section.id) }

  it "copies a section for an administrator and returns to its page editor" do
    sign_in create(:user, access: "super")
    expect { post path, params: { section_name: "New details" } }.to change(Section, :count).by(1).and change(Cell, :count).by(1)
    expect(response).to have_http_status(:see_other)
    expect(response).to redirect_to(edit_admin_page_path(section.page, section_name: "New details"))
  end

  it "requires login" do
    expect { post path, params: { section_name: "New details" } }.not_to change(Section, :count)
    expect(response).to redirect_to(new_user_session_path)
  end

  it "rejects non-admin users without creating records" do
    sign_in create(:user, access: "read_only")
    expect { post path, params: { section_name: "New details" } }.not_to change { [ Section.count, Cell.count ] }
    expect(response).to redirect_to(edit_admin_page_path(section.page))
    expect(flash[:alert]).to include("not permitted")
  end

  it "does not duplicate a section through another page's URL" do
    sign_in create(:user, access: "super")
    other = create(:page)
    expect {
      post admin_duplicate_page_section_path(page_id: other.id, id: section.id)
    }.not_to change { [ Section.count, Cell.count ] }
    expect(response).to have_http_status(:not_found)
  end

  it "rejects a blank section name without creating records" do
    sign_in create(:user, access: "super")
    expect { post path, params: { section_name: "  " } }.not_to change { [ Section.count, Cell.count ] }
    expect(response).to redirect_to(edit_admin_page_path(section.page))
    expect(flash[:alert]).to include("can't be blank")
  end

  it "rejects an existing section name rather than silently changing it" do
    sign_in create(:user, access: "super")
    expect { post path, params: { section_name: section.section_name } }.not_to change { [ Section.count, Cell.count ] }
    expect(flash[:alert]).to include("has already been taken")
  end

  it "duplicates all group members on the page and returns to the selected copy" do
    sign_in create(:user, access: "super")
    section.update!(section_group: "Details group")
    sibling = create(:section, page: section.page, section_group: section.section_group, section_order: 10)
    create(:cell, section: sibling)
    create(:section, section_group: section.section_group)

    expect { post path, params: { section_name: "New details group" } }
      .to change(Section, :count).by(2).and change(Cell, :count).by(2)
    expect(response).to redirect_to(edit_admin_page_path(section.page, section_name: "New details group"))
    expect(flash[:notice]).to eq("Section group duplicated successfully.")
    expect(section.page.sections.where(section_group: "New details group").pluck(:section_order)).to eq([20, 30])
  end
end
