require 'rails_helper'

RSpec.describe "Admin Site Setups", type: :system do
  let(:admin_user) { create(:user, access: "super") }
  let!(:site_setup) { SiteSetup.find_by(default_setup: true) }

  before do
    if ENV["DEBUG"].present? || ENV["RSPEC_DEBUG"].present?
      driven_by(:selenium_chrome)
    else
      driven_by(:selenium_chrome_headless)
    end

    login_as(admin_user)
  end

  describe "New/Edit Site Setup" do
    describe "New Site Setup Form" do
      before { visit new_admin_site_setup_path }

      it "renders the correct header" do
        expect(page).to have_selector("h1", text: "New Site Setup")
      end

      it "renders all form fields" do
        expect(page).to have_field("site_setup[configuration_name]", type: "text")
        expect(page).to have_field("site_setup[owner_name]", type: "text")
        expect(page).to have_field("site_setup[site_name]", type: "text")
        expect(page).to have_field("site_setup[site_domain]", type: "text")
        expect(page).to have_field("site_setup[site_host]", type: "text")
        expect(page).to have_field("site_setup[site_url]", type: "text")
        expect(page).to have_select("site_setup[header_background]")
        expect(page).to have_select("site_setup[header_text_color]")
        expect(page).to have_select("site_setup[footer_background]")
        expect(page).to have_select("site_setup[footer_text_color]")
        expect(page).to have_select("site_setup[container_background]")
        expect(page).to have_select("site_setup[container_text_color]")
        expect(page).to have_field("Background Image", type: "text")
        expect(page).to have_field("Facebook URL", type: "text")
        expect(page).to have_field("Twitter URL", type: "text")
        expect(page).to have_field("Instagram URL", type: "text")
        expect(page).to have_field("Linkedin URL", type: "text")
        expect(page).to have_field("GitHub URL", type: "text")
      end

      it "creates a new site setup successfully" do
        fill_in "site_setup[configuration_name]", with: "alternate"
        fill_in "site_setup[owner_name]", with: "Test User"
        fill_in "site_setup[site_name]", with: "Test"
        fill_in "site_setup[site_domain]", with: "example.com"
        fill_in "site_setup[site_host]", with: "example.com"
        fill_in "site_setup[site_url]", with: "https://example.com"

        select "Default", from: "site_setup[header_background]"
        select "White", from: "site_setup[header_text_color]"
        select "Default", from: "site_setup[footer_background]"
        select "White", from: "site_setup[footer_text_color]"
        select "White", from: "site_setup[container_background]"
        select "Black", from: "site_setup[container_text_color]"

        click_button "Save Site Setup"

        expect(page).to have_current_path(admin_site_setups_path(turbo: false))
        expect(page).to have_content("Site Setup created successfully.")
      end
    end

    describe "Edit Site Setup Form" do
      before { visit edit_admin_site_setup_path(site_setup) }

      it "renders the correct title and header" do
        expect(page).to have_selector("h1", text: "Edit Site Setup")
      end

      it "updates the site setup successfully" do
        fill_in "site_setup[owner_name]", with: "Example User"
        fill_in "site_setup[site_name]", with: "Example"

        click_button "Save Site Setup"

        expect(page).to have_current_path(admin_site_setups_path(turbo: false))
        expect(page).to have_content("Site Setup updated successfully.")
        expect(site_setup.reload.owner_name).to eq("Example User")
        expect(site_setup.reload.site_name).to eq("Example")
      end
    end
  end

  describe "Index Page" do
    before { visit admin_site_setups_path }

    it "lists all site setups with their attributes" do
      within ".scrollable-container" do
        expect(page).to have_content("default")
      end
    end

    it "navigates to the new site setup page" do
      click_link "New Site Setup"
      expect(page).to have_current_path(new_admin_site_setup_path)
    end

    it "renders action links for each site setup" do
      within ".scrollable-container" do
        expect(page).to have_link("Edit", href: edit_admin_site_setup_path(site_setup))
        expect(page).to have_link("Delete", href: admin_destroy_site_setup_path(site_setup))
      end
    end
  end
end
