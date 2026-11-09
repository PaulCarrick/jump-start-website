require 'rails_helper'

# The admin draws its own, larger tooltips instead of the browser's small ones.
RSpec.describe 'Tooltips in the admin', type: :system do
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }

  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
  end

  def tooltip_font_size = page.evaluate_script("parseFloat(getComputedStyle(document.querySelector('.admin-tooltip')).fontSize)")

  it 'shows a button title in a larger tooltip and puts the title back afterwards' do
    create(:image_file, name: 'birds-1', group: 'birds')
    visit admin_image_files_path
    button = find('.admin-media-thumb[title="Details of birds-1"]')
    button.hover
    expect(page).to have_css('.admin-tooltip.is-visible', text: 'Details of birds-1')
    expect(tooltip_font_size).to be >= 15
    expect(button[:title]).to be_blank
    find('h1', text: 'Media').hover
    expect(page).to have_no_css('.admin-tooltip.is-visible')
    expect(page).to have_css('.admin-media-thumb[title="Details of birds-1"]')
  end

  it 'shows the section handles\' tooltips on a page in editing mode' do
    page_record = create(:page, name: 'garden', section: 'garden-content', title: 'Garden')
    section = create(:section, page: page_record, content_type: 'garden-content', section_name: 'garden-intro')
    create(:cell, section: section, section_name: 'garden-intro', image: nil, link: nil, content: '<p>Roses</p>')
    visit page_path('garden')
    click_button 'Edit Page'
    find("[data-section-id='#{section.id}']").hover
    find('.page-edit-section-handle button[title="Move this section down"]').hover
    expect(page).to have_css('.admin-tooltip.is-visible', text: 'Move this section down')
    expect(tooltip_font_size).to be >= 15
  end
end
