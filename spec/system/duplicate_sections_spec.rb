require "rails_helper"

RSpec.describe "Duplicate a section from the page editor", type: :system do
  let!(:section) { create(:section, section_name: "Overview", section_order: 2) }
  let!(:cell) { create(:cell, section: section, cell_name: "Overview column", content: "<p>Duplicated content</p>") }

  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: "super"))
  end

  it "asks for a section name and saves the copies under the entered names" do
    visit edit_admin_page_path(section.page)
    button = "duplicate-section-#{section.id}-button"
    accept_prompt(with: "New overview") { click_button button }
    expect(page).to have_current_path(edit_admin_page_path(section.page, section_name: "New overview", return_url: admin_pages_path))
    expect(page).to have_content("Section duplicated successfully.")
    expect(page).to have_button("Duplicate Section", count: 2)
    copy = section.page.sections.find_by!(section_name: "New overview")
    expect(copy.cells.first.content).to eq(cell.content)
    expect(copy.cells.first.cell_name).to eq("Overview column Copy")
    within(find(:id, copy.section_name, match: :first)) { expect(page).to have_link("Edit Column") }
    page.execute_script("document.getElementById(arguments[0]).scrollIntoView({block: 'start', behavior: 'instant'});", copy.section_name)
    page.save_screenshot(Rails.root.join("tmp/named-section-duplication.png"))

    accept_prompt(with: "Another overview") { click_button button }
    expect(page).to have_current_path(edit_admin_page_path(section.page, section_name: "Another overview", return_url: admin_pages_path))
    expect(page).to have_button("Duplicate Section", count: 3)
    expect(section.reload.cells.count).to eq(1)
  end

  it "creates nothing when the name prompt is canceled" do
    visit edit_admin_page_path(section.page)
    dismiss_prompt { click_button "duplicate-section-#{section.id}-button" }
    expect(page).to have_current_path(edit_admin_page_path(section.page))
    expect(section.page.sections.count).to eq(1)
  end

  it "handles blank and already-used names without creating copies" do
    visit edit_admin_page_path(section.page)
    button = "duplicate-section-#{section.id}-button"
    accept_alert("Please enter a section name.") do
      accept_prompt(with: "  ") { click_button button }
    end
    expect(section.page.sections.count).to eq(1)
    accept_prompt(with: section.section_name) { click_button button }
    expect(page).to have_current_path(edit_admin_page_path(section.page, return_url: admin_pages_path))
    expect(page).to have_content("has already been taken")
    expect(section.page.sections.count).to eq(1)
  end

  it "offers group duplication and copies every member into the named group" do
    section.update!(section_group: "Overview group")
    sibling = create(:section, page: section.page, section_group: section.section_group, section_name: "Details")
    create(:cell, section: sibling, content: "<p>Grouped details</p>")
    visit edit_admin_page_path(section.page)
    expect(page).to have_button("Duplicate Group", count: 2)

    accept_prompt("Name for the duplicated section group:", with: "New overview group") do
      click_button "duplicate-section-#{section.id}-button"
    end
    expect(page).to have_content("Section group duplicated successfully.")
    expect(section.page.sections.where(section_group: "New overview group").count).to eq(2)
    expect(section.page.sections.where(section_group: "Overview group").count).to eq(2)
    expect(page).to have_button("Duplicate Group", count: 4)
    page.save_screenshot(Rails.root.join("tmp/grouped-section-duplication.png"))
  end
end
