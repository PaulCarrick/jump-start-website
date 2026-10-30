require 'rails_helper'

RSpec.describe 'Draft publishing workflow', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
  end

  it 'previews unpublished column changes and deploys the related records together' do
    record = create(:page)
    section = create(:section, page: record, content_type: record.section)
    cell = create(:cell, section: section, content: '<p>Original live text</p>', image: nil, link: nil)
    visit edit_admin_cell_path(cell)
    enter_column_text 'Unpublished column text'
    click_button 'Save Column'
    expect(page).to have_current_path(admin_cells_path, ignore_query: true)
    visit page_path(record.name)
    expect(page).to have_content('Original live text')
    expect(page).to have_no_content('Unpublished column text')
    visit page_path(record.name, preview: 'draft')
    expect(page).to have_content('Draft preview')
    expect(page).to have_content('Unpublished column text')
    visit admin_publishing_path
    expect(page).to have_content('Update')
    page.save_screenshot(Rails.root.join('tmp/publishing-review.png'))
    fill_in 'Deployment summary', with: 'Updated page content'
    click_button 'Deploy Changes'
    expect(page).to have_content('Changes deployed successfully')
    expect(page).to have_content('No pending changes')
    visit page_path(record.name)
    expect(page).to have_content('Unpublished column text')
    expect(page).to have_no_content('Original live text')
  end
end
