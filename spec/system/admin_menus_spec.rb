require 'rails_helper'

RSpec.describe "Admin Menus screen", type: :system do
  let(:admin_user) { create(:user, access: "super") }
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:menu_item_1) { create(:menu_item, menu_type: "Main", label: "Item 1", menu_order: 1, link: "/one") }
  let!(:menu_item_2) { create(:menu_item, menu_type: "Main", label: "Item 2", menu_order: 2, link: "/two") }

  before do
    driven_by(:selenium_chrome_headless)
    login_as(admin_user)
  end

  def node(item)
    find(".admin-menu-node[data-id='#{item.id}']")
  end

  it "is the Menus entry in the sidebar" do
    visit admin_root_path
    within("#admin-sidebar") { click_link "Menus" }
    expect(page).to have_current_path(admin_menus_path)
    expect(page).to have_css(".admin-menu-label", text: "Item 1")
  end

  it "moves an item with the arrow buttons and saves it" do
    visit admin_menus_path
    within(node(menu_item_2)) { click_button "Move Item 2 up" }
    expect(page).to have_css(".admin-menu-status", text: "Saved as a draft")
    expect(MenuItem.find(menu_item_2.id).menu_order).to be < MenuItem.find(menu_item_1.id).menu_order

    within(node(menu_item_1)) { click_button "Put Item 1 inside the item above" }
    expect(page).to have_css(".admin-menu-status", text: "Saved as a draft")
    expect(MenuItem.find(menu_item_1.id).parent_id).to eq(menu_item_2.id)

    visit admin_menus_path
    expect(page).to have_css(".admin-menu-node[data-id='#{menu_item_2.id}'] .admin-menu-node[data-id='#{menu_item_1.id}']")
  end

  it "edits the chosen item in the side panel" do
    visit admin_menus_path
    click_link "Item 1"
    within(".admin-menu-panel") do
      fill_in "Label*", with: "First item"
      fill_in "Links to", with: "/first"
      click_button "Save item"
    end
    # Wait for the redirect before reading the page.
    expect(page).to have_current_path(admin_menus_path(kind: "header", selected: menu_item_1.id))
    expect(page).to have_content("Menu Item updated successfully.")
    expect(page).to have_css(".admin-menu-label", text: "First item")
  end

  it "refuses an unsafe link from the side panel" do
    visit admin_menus_path(selected: menu_item_1.id)
    within(".admin-menu-panel") do
      fill_in "Links to", with: "javascript:alert(1)"
      click_button "Save item"
    end
    expect(page).to have_current_path(/edit/)
    expect(page).to have_content("must be a page on this site")
    expect(MenuItem.find(menu_item_1.id).link).to eq("/one")
  end

  it "adds an item to the footer" do
    visit admin_menus_path(kind: "footer")
    click_link "Add an item"
    within(".admin-menu-panel") do
      fill_in "Label*", with: "New footer link"
      fill_in "Links to", with: "https://example.com"
      click_button "Add item"
    end
    expect(page).to have_current_path(admin_menus_path(kind: "footer"))
    expect(page).to have_css(".admin-menu-label", text: "New footer link")
  end
end
