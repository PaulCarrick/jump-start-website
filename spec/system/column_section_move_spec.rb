require 'rails_helper'

# A column's "Section this column belongs to" moves the column; it does not
# rename the section. The editor says so, warns while a move is set, and asks
# before saving one.
RSpec.describe 'Moving a column to another section', type: :system do
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:page_record) { create(:page, name: 'garden', section: 'garden-content', title: 'Our Garden') }
  let!(:roses) { create(:section, page: page_record, content_type: 'garden-content', section_name: 'roses', section_order: 10, image: nil, description: nil) }
  let!(:tulips) { create(:section, page: page_record, content_type: 'garden-content', section_name: 'tulips', section_order: 20, image: nil, description: nil) }
  let!(:column) { create(:cell, section: roses, section_name: 'roses', cell_name: 'roses_text', image: nil, link: nil, content: '<p>Roses in bloom</p>') }

  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
  end

  def choose_section(name)
    find('#section_name').click
    find('#section_name').send_keys(name)
    find('#section_name').send_keys(:enter)
  end

  # The column editor of the Columns list, where a column's section can be changed.
  def open_advanced
    visit edit_admin_cell_path(column)
    expect(page).to have_content('Section this column belongs to')
    expect(page).to have_content('Choosing another section moves this column there.')
  end

  it 'warns while a move is set, and can be undone before saving' do
    open_advanced
    expect(page).to have_no_css('.cell-section-field .alert')
    choose_section 'tulips'
    expect(page).to have_css('.cell-section-field .alert', text: 'When you save, this column moves from roses to tulips.')
    click_button 'Keep it in roses'
    expect(page).to have_no_css('.cell-section-field .alert')
  end

  it 'asks before saving a move, and leaves the column where it was when the answer is no' do
    open_advanced
    choose_section 'tulips'
    dismiss_confirm(/Move this column out of the section “roses” and into “tulips”/) { click_button 'Save Column' }
    expect(Cell.find(column.id).section_id).to eq(roses.id)

    accept_confirm { click_button 'Save Column' }
    expect(page).to have_current_path(admin_cells_path, ignore_query: true)
    expect(Cell.find(column.id).section_id).to eq(tulips.id)
    expect(Cell.find(column.id).section_name).to eq('tulips')
  end
end

RSpec.describe 'The section field in the page workspace', type: :system do
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:page_record) { create(:page, name: 'garden', section: 'garden-content', title: 'Our Garden') }
  let!(:roses) { create(:section, page: page_record, content_type: 'garden-content', section_name: 'roses', image: nil, description: nil) }
  let!(:column) { create(:cell, section: roses, section_name: 'roses', cell_name: 'roses_text', image: nil, link: nil, content: '<p>Roses</p>') }

  it 'is read-only and points to where a section is renamed' do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
    visit admin_page_workspace_path(page_record, cell: column.id)
    within('.workspace-panel') { click_button 'Advanced' }
    expect(find('#section_name', visible: :all)[:readonly]).to be_truthy
    expect(page).to have_content("To rename this section, change its Section name in the section's panel.")
  end
end
