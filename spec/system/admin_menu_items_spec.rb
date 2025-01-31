require 'rails_helper'

RSpec.describe "Admin Menu Items", type: :system do
  let(:admin_user) { create(:user, access: "super") }
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:menu_item_1) { create(:menu_item, label: "Item 1", menu_order: 1, link: "https://example.com/item1") }
  let!(:menu_item_2) { create(:menu_item, label: "Item 2", menu_order: 2, link: "https://example.com/item2") }

  before do
    if ENV["DEBUG"].present? || ENV["RSPEC_DEBUG"].present?
      driven_by(:selenium_chrome)
    else
      driven_by(:selenium_chrome_headless)
    end

    login_as(admin_user)
  end

  describe "New/Edit Pages" do
    describe "New Menu Item Form" do
      before { visit new_admin_menu_item_path }

      it "renders the correct title and header" do
        expect(page).to have_title("#{site_setup.site_name} - Admin Dashboard: Menu Items")
        expect(page).to have_selector("h1", text: "New Menu Item")
      end

      it "renders all form fields" do
        expect(page).to have_field("menu_item[label]", type: "text")
        expect(page).to have_field("Icon", type: "text")
        expect(page).to have_field("Link", type: "text")
        expect(page).to have_field("menu_item[menu_order]", type: "number")
      end

      it "creates a new menu item successfully" do
        fill_in "menu_item[label]", with: "New Menu"
        select "Main", from: "menu_item[menu_type]"
        fill_in "menu_item[menu_order]", with: 2
        click_button "Save Menu Item"
        expect(page).to have_current_path(admin_menu_items_path(turbo: false))
        expect(page).to have_content("Menu Item created successfully.")
      end
    end

    describe "Edit Menu Item Form" do
      let!(:existing_menu_item) { create(:menu_item, menu_type: "Main", label: "Existing Menu", menu_order: 1) }

      before { visit edit_admin_menu_item_path(existing_menu_item) }

      it "renders the correct title and header" do
        expect(page).to have_title("#{site_setup.site_name} - Admin Dashboard: Menu Items")
        expect(page).to have_selector("h1", text: "Edit Menu Item")
      end

      it "pre-fills existing data into the form fields" do
        expect(page).to have_field("menu_item[label]", with: "Existing Menu")
        expect(page).to have_field("menu_item[menu_order]", with: "1")
      end

      it "updates the menu item successfully" do
        fill_in "menu_item[label]", with: "Updated Menu"
        click_button "Save Menu Item"

        expect(page).to have_current_path(admin_menu_items_path(turbo: false))
        expect(page).to have_content("Menu Item updated successfully.")
        expect(existing_menu_item.reload.label).to eq("Updated Menu")
      end
    end
  end

  describe "Index Page" do
    before { visit admin_menu_items_path }

    it "renders the correct title" do
      expect(page).to have_title("#{site_setup.site_name} - Admin Dashboard: Menu Items")
    end

    it "lists all menu items with their attributes" do
      within ".scrollable-container" do
        expect(page).to have_content("Item 1")
        expect(page).to have_content("Item 2")
      end
    end

    it "navigates to the new menu item page" do
      click_link "New Menu Item"
      expect(page).to have_current_path(new_admin_menu_item_path)
    end

    it "renders action links for each menu item" do
      within ".scrollable-container" do
        expect(page).to have_link("Edit", href: edit_admin_menu_item_path(menu_item_1))
        expect(page).to have_link("Delete", href: admin_destroy_menu_item_path(menu_item_1))
      end
    end
  end
end
