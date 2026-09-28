require 'rails_helper'

RSpec.describe "Admin Sections", type: :system do
  def search_sections(description)
    visit admin_sections_path

    expect(page).to have_field(name: 'q[description_cont]')
    fill_in "q[description_cont]", with: description
    click_button "Search Sections"
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
        expect(page).to have_content("Test Description")
      end
    end

    it "renders action links for each section" do
      expect(page).to have_link("Clear Sort", href: admin_sections_path(clear_sort: true))
      expect(page).to have_link("View", href: admin_section_path(section))
      expect(page).to have_link("Edit", href: edit_admin_section_path(section))
      expect(page).to have_link("Delete", href: "#{admin_section_path(section)}/delete")
    end

  end

  # "navigates to the new section page" and the "New Section Page" describe
  # block were removed along with the standalone /admin/sections/new form -
  # sections are only ever created in the context of a page now, via
  # Admin::PagesController#add_section_to_page.

  describe "Edit Section Page" do
    before { visit edit_admin_section_path(section) }

    it "Has a CSRF Token" do
      expect(page).to have_selector("meta[name='csrf-token']", visible: false)
    end

    it "displays the correct title" do
      expect(page).to have_title("#{site_setup.site_name} - Admin Dashboard: Sections")
    end

    # These 2 tests used to fill in Section-level fields (#sectionName, #image,
    # #link, the "description" Quill editor, #rowStyle, margins) directly.
    # SectionEditor.tsx no longer exposes any of that: content now lives on
    # per-cell records, and the section-level editor only shows once the
    # section has at least one cell (hasCells(sectionData)). This factory
    # section has none (same as it would for any pre-Cell-refactor section
    # that hasn't had columns generated for it yet), so the real UI shows the
    # "Generate Columns" prompt instead of a pre-filled form - there's nothing
    # to pre-fill via the UI, since the old image/link/description fields
    # aren't rendered anywhere in this component any more.
    it "shows the Generate Columns screen for a section with no cells" do
      expect(page).to have_selector("#GenerateCells")
      expect(page).to have_content("Templates:")
      expect(page).to have_button("Generate Columns")
    end

    it "generates columns and updates the section successfully" do
      select "Text Only", from: "cellTemplates"
      fill_in_quill_editor("content", with: "New column content.")
      click_button "Generate Columns"

      # Generating columns makes hasCells(sectionData) true, which switches
      # SectionEditor over to its section_name/section_order editor (ids are
      # "section_name"/"section_order" - renderSectionName/renderSectionOrder
      # use the raw attribute name as the DOM id, not a camelCased one).
      expect(page).to have_field("section_name")

      find("#section_name").set("Updated Section Name")
      find("#section_order").set("3")
      click_button "Save Section"

      # Save Section calls updateSection, a synchronous XHR (see sendRequest
      # in app/javascript/services/utilities.ts) - the PATCH has completed by
      # the time the click handler returns. There's no redirect afterward to
      # assert on: options.returnUrl is never set (the ERB partial passes
      # successPath, which SectionEditor.tsx doesn't read), so verify the
      # save against the database instead of the page.
      expect(section.reload.section_name).to eq("Updated Section Name")
      expect(section.reload.section_order).to eq(3)
      expect(section.cells.count).to eq(1)
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
