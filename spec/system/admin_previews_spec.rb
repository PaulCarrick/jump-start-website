require 'rails_helper'

RSpec.describe 'Admin read-only previews', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
  end

  it 'renders page, section and cell content without editor controls or field details' do
    section = create(:section)
    cell = create(:cell, section: section, image: nil, link: nil, content: '<p>Read-only preview content</p>')
    visit admin_page_path(section.page)
    expect(page).to have_current_path(page_path(section.page.name))
    expect(page).to have_css('#contents p', text: 'Read-only preview content')
    expect(page).to have_no_css('.admin-sidebar')
    [ admin_section_path(section), admin_cell_path(cell) ].each do |path|
      visit path
      within('.admin-main') do
        expect(page).to have_css('p', text: 'Read-only preview content')
        expect(page).to have_no_link('Edit Column')
        expect(page).to have_no_link('Delete Column')
        expect(page).to have_no_link('Edit Section')
        expect(page).to have_no_link('Edit Cell')
        expect(page).to have_no_content('Formatting:')
      end
    end
  end
end
