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
    expect(response).to have_http_status(:forbidden)
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
    expect(flash[:alert]).to include("enter a name")
  end

  it "rejects an existing section name rather than silently changing it" do
    sign_in create(:user, access: "super")
    expect { post path, params: { section_name: section.section_name } }.not_to change { [ Section.count, Cell.count ] }
    expect(flash[:alert]).to include("already used")
  end

  it "duplicates all group members on the page and returns to the selected copy" do
    sign_in create(:user, access: "super")
    section.update!(section_group: "Details group")
    sibling = create(:section, page: section.page, section_group: section.section_group, section_order: 10)
    create(:cell, section: sibling)
    create(:section, section_group: section.section_group)

    expect { post path, params: { section_name: "New details group" } }
      .to change(Section, :count).by(2).and change(Cell, :count).by(2)
    copies = Section.where(page_id: section.page_id, section_group: "New details group").order(:section_order)
    expect(response).to redirect_to(edit_admin_page_path(section.page, section_name: copies.first.section_name))
    expect(flash[:notice]).to start_with("Group duplicated as New details group")
    expect(copies.pluck(:section_order)).to eq([ 20, 30 ])
    expect(copies.pluck(:section_name)).to eq([ "New details group-Details", "New details group-#{sibling.section_name}" ])
  end

  it "answers the page's editing mode with the copies" do
    sign_in create(:user, access: "super")
    section.update!(section_group: "team")
    create(:section, page: section.page, section_group: "team", section_name: "Members", section_order: 10)
    post path, params: { section_name: "crew", group: 1 }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["sections"].map { |copy| copy["name"] }).to eq(%w[crew-Details crew-Members])
    expect(response.parsed_body["message"]).to include("at the end of the page")

    post path, params: { section_name: "Solo", group: 0 }, as: :json
    expect(response.parsed_body["sections"].map { |copy| copy["name"] }).to eq(%w[Solo])

    post path, params: { section_name: "crew", group: 1 }, as: :json
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body["error"]).to include("already a group")
  end

  it "returns to the copy in the page workspace" do
    sign_in create(:user, access: "super")
    post path, params: { section_name: "Workspace copy", workspace: 1 }
    copy = Section.find_by!(section_name: "Workspace copy")
    expect(response).to redirect_to(admin_page_workspace_path(section.page, section: copy.id))
    post path, params: { section_name: "Workspace copy", workspace: 1 }
    expect(response).to redirect_to(admin_page_workspace_path(section.page, section: section.id))
    expect(flash[:alert]).to include("already used")
  end

  it "renames a group and its sections together from the workspace" do
    sign_in create(:user, access: "super")
    section.update!(section_group: "team")
    other = create(:section, page: section.page, section_group: "team", section_name: "Members")
    patch admin_rename_page_section_group_path(section.page),
          params: { group: "team", new_group: "staff", section_id: section.id, names: { section.id => "staff-details", other.id => "staff-members" } }
    expect(response).to redirect_to(admin_page_workspace_path(section.page, section: section.id))
    expect(Section.where(section_group: "staff").order(:id).pluck(:section_name)).to eq(%w[staff-details staff-members])

    sign_in create(:user, access: "read_only")
    patch admin_rename_page_section_group_path(section.page), params: { group: "staff", new_group: "x", names: {} }
    expect(response).to have_http_status(:forbidden)
  end
end
