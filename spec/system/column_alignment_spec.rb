require 'rails_helper'

RSpec.describe 'Column alignment in previews and public pages', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    page.driver.browser.manage.window.resize_to(1400, 1000)
    login_as(create(:user, access: 'super'))
  end

  it 'keeps the first column top-aligned when another column retains center alignment' do
    content_page = create(:page, name: 'alignment-test', section: 'alignment-test')
    section = create(:section, page: content_page, content_type: content_page.section, section_name: 'alignment-row')
    create(:cell, section: section, section_name: section.section_name, cell_order: 1,
           content: '<h2>Top aligned title</h2>', image: nil, link: nil,
           formatting: { classes: 'col-lg-4', container_classes: 'align-items-start pt-5' })
    create(:cell, section: section, section_name: section.section_name, cell_order: 2,
           content: '<p>Tall neighboring content</p>' * 25, image: nil, link: nil,
           formatting: { classes: 'col-lg-8', container_classes: 'align-items-center pt-5' })

    visit page_path(content_page.name)
    expect(page).to have_css('#alignment-row h2', text: 'Top aligned title')
    row = find('#alignment-row')
    expect(row[:class].split).to include('align-items-start')
    expect(row[:class].split).not_to include('align-items-center')
    expect(row[:class].split.count('pt-5')).to eq(1)
    positions = page.evaluate_script("Array.from(document.querySelector('#alignment-row').children).map(c => c.getBoundingClientRect().top)")
    expect((positions[0] - positions[1]).abs).to be < 1

    visit edit_admin_page_path(content_page)
    expect(page).to have_css('#alignment-row h2', text: 'Top aligned title')
    expect(find('#alignment-row.admin-section-cells')[:class].split).to include('align-items-start')
    expect(find('#alignment-row.admin-section-cells')[:class].split).not_to include('align-items-center')
  end
end
