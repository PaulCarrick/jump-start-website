require 'rails_helper'

RSpec.describe "Search Page", type: :system do
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:test_page) { create(:page, name: "coding", section: "coding", title: "Discussions on coding") }
  let!(:matching_page) {
    create(:section,
           content_type:  "coding",
           description:   "A matching description about Purple People Eater",
           section_order: 1)
  }
  let!(:non_matching_page) {
    create(:section,
           content_type:  "coding",
           description:   "Pythons are popular",
           section_order: 2)
  }

  before do
    if ENV["DEBUG"].present? || ENV["RSPEC_DEBUG"].present?
      driven_by(:selenium_chrome)
    else
      driven_by(:selenium_chrome_headless)
    end
  end

  describe "Visiting the Search Page" do
    before { visit new_search_path }

    it "displays the correct page title" do
      expect(page).to have_title("#{site_setup.site_name} - Search")
    end

    it "displays the search form" do
      expect(page).to have_selector("form")
      expect(page).to have_field("Search site pages for")
      expect(page).to have_button("Search Site Pages")
    end
  end

  describe "Submitting the Search Form" do
    before { visit new_search_path }

    context "when a matching description is found" do
      it "displays the results" do
        fill_in "Search site pages for", with: "Purple People Eater"
        click_button "Search Site Pages"
        expect(page).to have_content("A matching description about Purple People Eater")
        expect(page).not_to have_content("Pythons are popular")
      end
    end

    context "when no matching description is found" do
      it "displays no results" do
        fill_in "Search site pages for", with: "Pythons"
        click_button "Search Site Pages"

        expect(page).not_to have_content("A matching description about Purple People Eater")
      end
    end
  end
end
