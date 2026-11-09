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
    expect(page).to have_content('Changed')
    expect(page).to have_content('Unpublished column text')
    page.save_screenshot(Rails.root.join('tmp/publishing-review.png'))
    fill_in 'Note for the history (optional)', with: 'Updated page content'
    accept_confirm(/Publish 1 change in 1 group/) { click_button 'Publish 1 change' }
    expect(page).to have_content('Changes deployed successfully')
    expect(page).to have_content('No pending changes')
    expect(page).to have_content('Updated page content')
    visit page_path(record.name)
    expect(page).to have_content('Unpublished column text')
    expect(page).to have_no_content('Original live text')
  end

  it 'publishes the ticked page and leaves the other as a draft' do
    garden = create(:page, name: 'garden', title: 'Garden')
    kitchen = create(:page, name: 'kitchen', title: 'Kitchen')
    PublishingContext.editing = true
    garden.update!(title: 'Our Garden')
    kitchen.update!(title: 'Our Kitchen')
    PublishingContext.editing = false

    visit admin_publishing_path
    expect(page).to have_button('Publish 2 changes')
    click_button 'Select none'
    expect(page).to have_button('Publish selected', disabled: true)
    check 'Our Garden'
    expect(page).to have_content('Ticked: 1 change in 1 group.')
    accept_confirm(/Our Garden/) { click_button 'Publish 1 change' }
    expect(page).to have_content('Changes deployed successfully')
    expect(page).to have_content('1 change is still waiting')
    expect(page).to have_css('.publish-group-title', text: 'Our Kitchen')
    expect(page).to have_no_css('.publish-group-title', text: 'Our Garden')
    expect(Page.live_versions.find_by(id: garden.id).title).to eq('Our Garden')
    expect(Page.live_versions.find_by(id: kitchen.id).title).to eq('Kitchen')
  ensure
    PublishingContext.reset
  end
end
