require 'rails_helper'

RSpec.describe "Admin Footer Items", type: :system do
  let(:admin_user) { create(:user, access: "super") }
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:footer_item_1) { create(:footer_item, label: "Item 1", footer_order: 1, link: "https://example.com/item1") }
  let!(:footer_item_2) { create(:footer_item, label: "Item 2", footer_order: 2, link: "https://example.com/item2") }

  before do
    if ENV["DEBUG"].present? || ENV["RSPEC_DEBUG"].present?
      driven_by(:selenium_chrome)
    else
      driven_by(:selenium_chrome_headless)
    end

    login_as(admin_user)
  end

  describe "New/Edit Pages" do
    describe "New Footer Item Form" do
      before { visit new_admin_footer_item_path }

      it "renders the correct title and header" do
        expect(page).to have_title("#{site_setup.site_name} - Admin Dashboard: Footer Items")
        expect(page).to have_selector("h1", text: "New Footer Item")
      end

      it "renders all form fields" do
        expect(page).to have_field("footer_item[label]", type: "text")
        expect(page).to have_field("Icon", type: "text")
        expect(page).to have_field("Link", type: "text")
        expect(page).to have_field("footer_item[footer_order]", type: "number")
      end

      it "creates a new footer item successfully" do
        fill_in "footer_item[label]", with: "New Footer"
        fill_in "footer_item[link]", with: "./test"
        fill_in "footer_item[footer_order]", with: 2
        sleep 1
        click_button "Save Footer Item"
        sleep 3

        expect(page).to have_current_path(admin_footer_items_path(turbo: false))
        expect(page).to have_content("Footer Item created successfully.")
      end
    end

    describe "Edit Footer Item Form" do
      let!(:existing_footer_item) { create(:footer_item, label: "Existing Footer", footer_order: 1) }

      before { visit edit_admin_footer_item_path(existing_footer_item) }

      it "renders the correct title and header" do
        expect(page).to have_title("#{site_setup.site_name} - Admin Dashboard: Footer Items")
        expect(page).to have_selector("h1", text: "Edit Footer Item")
      end

      it "pre-fills existing data into the form fields" do
        expect(page).to have_field("footer_item[label]", with: "Existing Footer")
        expect(page).to have_field("footer_item[footer_order]", with: "1")
      end

      it "updates the footer item successfully" do
        fill_in "footer_item[label]", with: "Updated Footer"
        sleep 1
        click_button "Save Footer Item"
        sleep 2

        expect(page).to have_current_path(admin_footer_items_path(turbo: false))
        expect(page).to have_content("Footer Item updated successfully.")
        expect(existing_footer_item.reload.label).to eq("Updated Footer")
      end
    end
  end

  describe "Index Page" do
    before { visit admin_footer_items_path }

    it "renders the correct title" do
      expect(page).to have_title("#{site_setup.site_name} - Admin Dashboard: Footer Items")
    end

    it "lists all footer items with their attributes" do
      within ".scrollable-container" do
        expect(page).to have_content("Item 1")
        expect(page).to have_content("Item 2")
      end
    end

    it "navigates to the new footer item page" do
      sleep 1
      click_link "New Footer Item"
      sleep 2
      expect(page).to have_current_path(new_admin_footer_item_path)
    end

    it "renders action links for each footer item" do
      within ".scrollable-container" do
        expect(page).to have_link("Edit", href: edit_admin_footer_item_path(footer_item_1))
        expect(page).to have_link("Delete", href: admin_destroy_footer_item_path(footer_item_1))
      end
    end
  end
end
