require 'rails_helper'

RSpec.describe 'Enabled switches', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
  end

  it 'saves the Rails page switch and keeps a disabled page editable' do
    record = create(:page)
    visit edit_admin_page_path(record)
    uncheck 'Enabled'
    click_button 'Save Page'
    expect(page).to have_current_path(admin_pages_path, ignore_query: true)
    expect(record.reload.enabled).to be(false)
    visit edit_admin_page_path(record)
    expect(page).to have_unchecked_field('Enabled')
  end

  it 'saves a React column switch without hiding its admin preview' do
    cell = create(:cell, image: nil, link: nil)
    visit edit_admin_cell_path(cell)
    uncheck 'Enabled'
    click_button 'Save Column'
    expect(page).to have_current_path(admin_cells_path, ignore_query: true)
    expect(cell.reload.enabled).to be(false)
    visit edit_admin_cell_path(cell)
    expect(page).to have_unchecked_field('Enabled')
  end
  it 'persists the section switch after saving and reopening from a page' do
    section = create(:section)
    create(:cell, section: section, image: nil, link: nil)
    visit edit_admin_section_path(section)
    uncheck 'Enabled'
    expect(page).to have_unchecked_field('Enabled')
    click_button 'Save Section'
    expect(page).to have_current_path(admin_sections_path, ignore_query: true)
    expect(section.reload.enabled).to be(false)
    visit edit_admin_section_path(section)
    expect(page).to have_unchecked_field('Enabled')
  end

end
