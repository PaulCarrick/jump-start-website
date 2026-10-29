require "rails_helper"

RSpec.describe "Admin section separators", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: "super"))
  end

  it "separates adjacent groups, sections and columns without outside lines" do
    website_page = create(:page)
    sections = [ "Work", "Work", "Travel", nil ].each_with_index.map do |group, index|
      create(:section, page: website_page, section_group: group, section_order: index * 10)
    end
    sections.each { |section| create(:cell, image: nil, link: nil, section: section, formatting: { classes: "col-6" }, content: "<p>Column content</p>") }
    create(:cell, image: nil, link: nil, section: sections.first, formatting: { classes: "col-6" }, content: "<p>Second column</p>")

    visit edit_admin_page_path(website_page)
    expect(page).to have_css(".admin-section-divider", count: 3)
    expect(page).to have_css(".admin-group-divider", count: 2)
    expect(page).to have_css(".admin-member-divider", count: 1)
    expect(page).to have_css(".admin-section-cell", count: 5)
    expect(page).to have_css(".admin-section-actions", count: 4)
    expect(page).to have_css(".admin-cell-divider", count: 1)
    expect(page.evaluate_script(<<~JS)).to eq([ "0px", "2px", "0px", "0px", "0px" ])
      Array.from(document.querySelectorAll('.admin-section-cell')).map(cell => getComputedStyle(cell).borderLeftWidth)
    JS
    expect(page.evaluate_script("getComputedStyle(document.querySelector('.admin-sidebar')).alignItems")).to eq("flex-start")
    expect(page.evaluate_script("getComputedStyle(document.querySelector('.admin-sidebar .nav-link')).whiteSpace")).to eq("nowrap")
    page.driver.browser.manage.window.resize_to(1440, 1800)
    page.save_screenshot(Rails.root.join("tmp/admin-section-separators.png"))
    page.execute_script("document.querySelectorAll('.admin-section-cell').forEach(cell => cell.style.width = '100%')")
    expect(page).to have_no_css(".admin-cell-divider")
  end
end
