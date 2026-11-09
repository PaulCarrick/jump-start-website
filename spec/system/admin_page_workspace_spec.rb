require 'rails_helper'

RSpec.describe "Page workspace", type: :system do
  let(:admin_user) { create(:user, access: "super") }
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:page_record) { create(:page, name: "garden", section: "garden-content", title: "Our Garden") }
  let!(:first_section) do
    create(:section, page: page_record, content_type: "garden-content", section_name: "garden-intro",
                     section_order: 10, image: nil, description: nil)
  end
  let!(:second_section) do
    create(:section, page: page_record, content_type: "garden-content", section_name: "garden-roses",
                     section_order: 20, image: nil, description: nil)
  end
  let!(:intro_cell) do
    create(:cell, section: first_section, section_name: "garden-intro", cell_name: "intro-text",
                  cell_order: 1, image: nil, link: nil, content: "<p>Welcome to the garden</p>")
  end
  let!(:roses_cell) do
    create(:cell, section: second_section, section_name: "garden-roses", cell_name: "roses-text",
                  cell_order: 1, image: nil, link: nil, content: "<p>Roses in bloom</p>")
  end

  before do
    driven_by(:selenium_chrome_headless)
    login_as(admin_user)
  end

  def outline_order
    all(".outline-section > .outline-row .outline-label").map(&:text)
  end

  it "opens from the Pages list, with the outline, the preview and the classic editor link" do
    visit admin_pages_path
    click_link "Our Garden"
    expect(page).to have_current_path(admin_page_workspace_path(page_record))
    expect(outline_order).to eq(%w[garden-intro garden-roses])
    within(".workspace-preview") do
      expect(page).to have_content("Welcome to the garden")
      expect(page).to have_content("Roses in bloom")
    end
    expect(page).to have_link("Classic editor", href: edit_admin_page_path(page_record))
  end

  it "selects a section by clicking it in the preview and saves its group" do
    visit admin_page_workspace_path(page_record)
    find(".workspace-block", text: "Roses in bloom").click
    expect(page).to have_current_path(admin_page_workspace_path(page_record, section: second_section.id))
    within(".workspace-panel") do
      expect(page).to have_content("Section: garden-roses")
      fill_in "Section group", with: "flowers"
    end
    wait_for_new_page { click_button "Save section" }
    expect(page).to have_current_path(admin_page_workspace_path(page_record, section: second_section.id))
    expect(page).to have_content("Section updated successfully.")
    expect(Section.find(second_section.id).section_group).to eq("flowers")
  end

  it "edits a column in the tabbed panel and returns to it" do
    visit admin_page_workspace_path(page_record, cell: intro_cell.id)
    within(".workspace-panel") do
      expect(page).to have_button("Content")
      expect(page).to have_button("Image")
      expect(page).to have_button("Layout")
      expect(page).to have_button("Advanced")
      expect(page).to have_button("Switch to HTML View **")
      enter_column_text "A new welcome"
    end
    wait_for_new_page { click_button "Save Column" }
    expect(page).to have_current_path(admin_page_workspace_path(page_record, cell: intro_cell.id))
    within(".workspace-preview") { expect(page).to have_content("A new welcome") }
    expect(Cell.find(intro_cell.id).content).to include("A new welcome")
  end

  it "moves a section with the arrow buttons" do
    visit admin_page_workspace_path(page_record)
    click_button "Move section garden-roses up"
    expect(page).to have_css(".outline-section:first-child", text: "garden-roses")
    expect(page).to have_no_css(".admin-menu-status", text: "Saving")
    expect(outline_order).to eq(%w[garden-roses garden-intro])
    expect(Section.find(second_section.id).section_order).to be < Section.find(first_section.id).section_order
    expect(find(".workspace-preview")).to have_text(/Roses in bloom.*Welcome to the garden/m)
  end

  it "adds a column to a section and opens it" do
    visit admin_page_workspace_path(page_record, section: first_section.id)
    wait_for_new_page { click_button "+ Add column" }
    expect(page).to have_content("Column added.")
    expect(Cell.where(section_id: first_section.id).count).to eq(2)
    added = Cell.where(section_id: first_section.id).order(:cell_order).last
    expect(page).to have_current_path(admin_page_workspace_path(page_record, cell: added.id))
    expect(added.cell_order).to eq(2)
  end

  it "duplicates a section after asking for its name" do
    visit admin_page_workspace_path(page_record, section: first_section.id)
    wait_for_new_page { accept_prompt(with: "garden-intro-copy") { click_button "Duplicate section" } }
    expect(page).to have_content("Section duplicated successfully.")
    copy = Section.find_by!(section_name: "garden-intro-copy")
    expect(page).to have_current_path(admin_page_workspace_path(page_record, section: copy.id))
  end

  it "deletes a column" do
    visit admin_page_workspace_path(page_record, cell: roses_cell.id)
    wait_for_new_page { accept_confirm { click_button "Delete this column" } }
    expect(page).to have_current_path(admin_page_workspace_path(page_record, section: second_section.id))
    expect(Cell.where(id: roses_cell.id)).not_to exist
  end

  it "changes the page title in the Page settings dialog" do
    visit admin_page_workspace_path(page_record)
    click_button "Page settings"
    within("#page-settings") { fill_in "Title", with: "The Garden" }
    wait_for_new_page { click_button "Save Page" }
    expect(page).to have_current_path(admin_page_workspace_path(page_record))
    expect(page).to have_css("h1", text: "The Garden")
  end

  it "adds a section through the layout chooser and removes it again on Cancel" do
    visit admin_page_workspace_path(page_record)
    click_link "+ Add section"
    expect(page).to have_current_path(%r{/admin/sections/\d+/edit})
    expect(Section.where(page_id: page_record.id).count).to eq(3)
    click_button "Cancel"
    expect(page).to have_current_path(%r{/admin/pages/#{page_record.id}/workspace})
    expect(Section.where(page_id: page_record.id).count).to eq(2)
  end
end
