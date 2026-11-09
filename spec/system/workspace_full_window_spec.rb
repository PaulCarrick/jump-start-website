require 'rails_helper'

# The page workspace's "Full-window editor": the editor panel alone, filling
# the window, for a column, a section or the page itself.
RSpec.describe 'The full-window editor', type: :system do
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:page_record) { create(:page, name: 'garden', section: 'garden-content', title: 'Our Garden') }
  let!(:roses) { create(:section, page: page_record, content_type: 'garden-content', section_name: 'roses', section_order: 10, image: nil, description: nil) }
  let!(:tulips) { create(:section, page: page_record, content_type: 'garden-content', section_name: 'tulips', section_order: 20, image: nil, description: nil) }
  let!(:column) { create(:cell, section: roses, section_name: 'roses', cell_name: 'roses_text', image: nil, link: nil, content: '<p>Roses in bloom</p>') }

  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
  end

  def full_window? = URI.parse(page.current_url).query.to_s.include?('full=1')

  it 'is offered beside View page, in a new tab, for what is being edited' do
    visit admin_page_workspace_path(page_record, cell: column.id)
    link = find_link('Full-window editor ↗')
    expect(link[:target]).to eq('_blank')
    expect(link[:href]).to end_with(admin_page_workspace_path(page_record, cell: column.id, full: 1))
    visit admin_page_workspace_path(page_record)
    expect(find_link('Full-window editor ↗')[:href]).to end_with(admin_page_workspace_path(page_record, full: 1))
  end

  it 'shows only the editor for a column, wide, and stays there after saving' do
    visit admin_page_workspace_path(page_record, cell: column.id, full: 1)
    expect(page).to have_no_css('.workspace-outline')
    expect(page).to have_no_css('.workspace-preview')
    expect(page).to have_no_css('.admin-sidebar', visible: true)
    expect(page).to have_css('.workspace-panel', text: 'Column 1: roses_text')
    page.driver.browser.manage.window.resize_to(1400, 900)
    widths = page.evaluate_script("[document.querySelector('.workspace-panel').getBoundingClientRect().width, document.querySelector('.admin-main').clientWidth]")
    expect(widths.first).to be > widths.last * 0.9
    enter_column_text 'Roses all summer'
    wait_for_new_page { click_button 'Save Column' }
    expect(full_window?).to be(true)
    expect(Cell.find(column.id).content).to include('Roses all summer')
    expect(page).to have_link('← Back to the workspace', href: admin_page_workspace_path(page_record, cell: column.id))
  end

  it 'edits a section and keeps the full window when duplicating it' do
    visit admin_page_workspace_path(page_record, section: tulips.id, full: 1)
    expect(page).to have_css('.workspace-panel', text: 'Section: tulips')
    within('.workspace-panel') do
      fill_in 'Name for the copy of this section', with: 'more-tulips'
      wait_for_new_page { click_button 'Duplicate section' }
    end
    expect(page).to have_content('Section duplicated as more-tulips')
    expect(full_window?).to be(true)
  end

  it 'edits the page itself, and the Editing list moves between page, sections and columns' do
    visit admin_page_workspace_path(page_record, full: 1)
    within('.workspace-panel') do
      expect(page).to have_content('Page: Our Garden')
      fill_in 'Title', with: 'Our Lovely Garden'
      wait_for_new_page { click_button 'Save Page' }
    end
    expect(page).to have_content('Page updated successfully.')
    expect(Page.pending_versions.find(page_record.id).title).to eq('Our Lovely Garden')
    expect(full_window?).to be(true)

    wait_for_new_page { select 'Section: tulips', from: 'Editing' }
    expect(page).to have_css('.workspace-panel', text: 'Section: tulips')
    wait_for_new_page { select 'Column 1: Roses in bloom', from: 'Editing' }
    expect(page).to have_css('.workspace-panel', text: 'Column 1: roses_text')
    expect(full_window?).to be(true)
  end
end
