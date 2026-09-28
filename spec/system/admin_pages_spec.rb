require 'nokogiri'
require 'rails_helper'

RSpec.describe "Admin Pages", type: :system do
  def search_pages(name)
    page_records = Page.by_page_name(name)

    expect(page_records.length).to eq(1)

    page_record = page_records[0]

    visit admin_pages_path

    expect(page).to have_link("View", href: admin_page_path(page_record))

    page_record
  end

  let(:admin_user) { create(:user, access: "super") }
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:page_record) do
    create(:page,
           name: "Test Page",
           section: "Test Section",
           title: "Test Title",
           access: "Public")
  end
  let!(:section) do
    create(:section,
           page:          page_record,
           content_type:  "Test Section",
           section_name:  "Test Section Name",
           section_order: 1,
           image:         "test_image.jpg",
           link:          "https://example.com",
           formatting:    "{ \"row_class\": \"text-left\" }",
           description:   "<p>Test Description</p>")
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
    before { visit admin_pages_path }

    it "displays the correct title" do
      expect(page).to have_title("#{site_setup.site_name} - Admin Dashboard: Pages")
    end

    it "lists all pages with their attributes" do
      within ".scrollable-container" do
        expect(page).to have_content("Test Page")
        expect(page).to have_content("Test Section")
        expect(page).to have_content("Test Title")
        expect(page).to have_content("Public")
      end
    end

    it "renders action links for each page" do
      expect(page).to have_link("Edit", href: edit_admin_page_path(page_record))
      expect(page).to have_link("Delete", href: "#{admin_page_path(page_record)}/delete")
    end

    it "navigates to the new page form" do
      click_link "New page"
      expect(page).to have_current_path(new_admin_page_path)
    end
  end

  describe "New Page" do
    before { visit new_admin_page_path }

    it "displays the correct title" do
      expect(page).to have_title("#{site_setup.site_name} - Admin Dashboard: Pages")
    end

    # These 2 tests used to fill in an ERB form ("page[name]", "Section",
    # "Title", "Access") - but new.html.erb renders PageEditor.tsx (a React
    # component), not that form. Admin::AbstractAdminController#new already
    # builds a real (unpersisted) Page via get_item, so PageEditor's needPage
    # is false from the start - there's no separate "Generate Page" step here,
    # just the main editor, pre-filled from the generated default page/section
    # names. Its Section Name field is rendered via renderSectionName called
    # without an explicit attribute, so it defaults to id="section_name" (not
    # "section").

    it "renders the form with required fields" do
      expect(page).to have_field("name", type: "text")
      expect(page).to have_field("section_name", type: "text")
      expect(page).to have_field("title", type: "text")
      expect(page).to have_field("access", type: "text")
    end

    it "creates a new page successfully" do
      fill_in "name", with: "New Page"
      fill_in "section_name", with: "New Section"
      fill_in "title", with: "New Title"
      fill_in "access", with: "Private"
      click_button "Save Page"

      # Unlike the ERB-form-based Edit Page flow (whose controller redirect
      # literally bakes "?turbo=false" into the URL, which is why that test
      # below matches admin_pages_path(turbo: false)), PageEditor.tsx redirects
      # via `window.location.href = options.returnUrl`, and new.html.erb sets
      # returnUrl to the plain admin_pages_url with no turbo param.
      expect(page).to have_current_path(admin_pages_path)
      expect(page).to have_content("New Page")
      expect(page).to have_content("Private")
    end
  end

  describe "Edit Page" do
    before { visit edit_admin_page_path(page_record) }

    it "displays the correct title" do
      expect(page).to have_title("#{site_setup.site_name} - Admin Dashboard: Pages")
    end

    it "pre-fills the form with existing data" do
      expect(page).to have_field("page[name]", with: "Test Page")
      expect(page).to have_field("Section", with: "Test Section")
      expect(page).to have_field("Title", with: "Test Title")
      expect(page).to have_field("Access", with: "Public")
    end

    it "updates the page successfully" do
      fill_in "Title", with: "Updated Title"
      click_button "Save Page"

      expect(page).to have_current_path(admin_pages_path(turbo: false))
      expect(page).to have_content("Updated Title")
    end
  end

  describe "Show Page" do
    it "shows the page details" do
      home_page = search_pages("home")

      expect(page).to have_link("View", href: admin_page_path(page_record))
      find(:xpath, "//a[text()='View' and @href='#{admin_page_path(page_record)}']").click

      stripped_text = Nokogiri::HTML(page_record&.sections&.first&.description).text.strip

      expect(page).to have_content(stripped_text)
    end
  end

  describe "Delete Functionality" do
    before { visit admin_pages_path }

    it "deletes an page successfully" do
      click_link "Delete", href: "#{admin_destroy_page_path(page_record)}"
      page.driver.browser.switch_to.alert.accept # Confirm alert

      # Checking for "Test Page" (page_record's name) is unreliable: the
      # db:replicate dev data (see spec/rails_helper.rb) includes an
      # unrelated real page named "test-page" whose title is literally
      # "Test Page", so that substring can still be present after a correct
      # delete. page_record's title, "Test Title", is not shared by that row.
      expect(page).not_to have_content("Test Title")
    end
  end
end
