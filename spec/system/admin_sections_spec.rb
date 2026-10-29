require 'rails_helper'

RSpec.describe "Admin Sections", type: :system do
  def search_sections(description)
    visit admin_sections_path

    expect(page).to have_field(name: 'q[description_cont]')
    fill_in "q[description_cont]", with: description
    click_button "Search Sections"
    expect(page).to have_current_path(/[?&]q(?:%5B|\[)/)
  end

  let(:admin_user) { create(:user, access: "super") }
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:image_file) do
    create(:image_file,
           name:        "1-test-image",
           caption:     "Test Caption",
           description: "Test Description",
           mime_type:   "image/jpeg",
           group:       "Test Group",
           slide_order: 1)
  end

  let!(:updated_image_file) do
    create(:image_file,
           name:        "2-test-image",
           caption:     "Updated Test Caption",
           description: "Updated Test Description",
           mime_type:   "image/jpeg",
           group:       "Test Group",
           slide_order: 2)
  end

  let!(:section) do
    create(:section,
           content_type: "Test Content Type",
           section_name: "Test Section Name",
           section_order: nil,
           image: "ImageFile:1-test-image",
           link: "https://example.com",
           description: "<p>Test Description</p>",
           row_style: "text-single",
           image_attributes: {},
           text_attributes: {
             margin_top: "mt-5",
             margin_left: "ms-5",
             margin_right: "me-5",
             margin_bottom: "mb-5",
             background_color: "red"
           },
           formatting: {
             row_style: "text-single",
             text_styles: "background-color: red",
             text_classes: "mt-5 ms-5 mb-5 me-5"
           })
  end

  before do
    if ENV["DEBUG"].present? || ENV["RSPEC_DEBUG"].present?
      driven_by(:selenium_chrome)
    else
      driven_by(:selenium_chrome_headless)
    end

    login_as(admin_user)
  end

  describe "Index Page" do
    before { search_sections("Test Description") }

    it "displays the correct title" do
      expect(page).to have_title("#{site_setup.site_name} - Admin Dashboard: Sections")
    end

    it "lists all sections with their attributes" do
      within ".auto-size" do
        expect(page).to have_content("Test Content Type")
        expect(page).to have_content("Test Section Name")
        expect(page).to have_content("1-test-image")
        expect(page).to have_content("https://example.com")
      end
    end

    it "renders action links for each section" do
      expect(page).to have_link("Clear Sort", href: admin_sections_path(clear_sort: true))
      expect(page).to have_link("View", href: admin_section_path(section))
      expect(page).to have_link("Edit", href: edit_admin_section_path(section))
      expect(page).to have_link("Delete", href: "#{admin_section_path(section)}/delete")
    end

    it "opens the section editor" do
      click_link "Edit", href: edit_admin_section_path(section)
      expect(page).to have_button("Generate Columns")
    end
  end

  describe "New Section Page" do
    it "offers column templates for an empty section" do
      visit new_admin_section_path
      expect(page).to have_button("Generate Columns")
      expect(page).to have_content("Templates:")
    end
  end

  describe "Edit Section Page" do
    let!(:cell) { create(:cell, section: section, section_name: section.section_name) }

    it "loads the section group and order" do
      section.update!(section_group: "Introduction")
      visit edit_admin_section_path(section)
      expect(page).to have_field("sectionGroup", with: "Introduction")
      expect(page).to have_field("section_order", with: "")
    end

    it "saves and clears the section group" do
      visit edit_admin_section_path(section)
      fill_in "sectionGroup", with: "Introduction"
      click_button "Save Section"
      expect(section.reload.section_group).to eq("Introduction")

      visit edit_admin_section_path(section)
      fill_in "sectionGroup", with: ""
      click_button "Save Section"
      expect(section.reload.section_group).to eq("")
    end
  end

  describe "Show Section Page" do
    before { visit admin_section_path(section) }

    it "displays the correct title" do
      expect(page).to have_title("#{site_setup.site_name} - Admin Dashboard: Sections")
    end

    it "shows the section details" do
      expect(page).to have_content("Test Content Type")
      expect(page).to have_content("Test Section Name")
      expect(page).to have_content("1")
      expect(page).to have_content("ImageFile:1-test-image")
      expect(page).to have_content("https://example.com")
      expect(page).to have_content("text-single")
      expect(page).to have_content("Test Description")
    end
  end
end
