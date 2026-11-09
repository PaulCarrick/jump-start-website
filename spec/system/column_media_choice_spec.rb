require 'rails_helper'

# The column editor's Image tab: one list of pictures, slide shows (image
# groups) and videos, each stored with the right reference.
RSpec.describe 'Choosing a picture, slide show or video for a column', type: :system do
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:page_record) { create(:page, name: 'garden', section: 'garden-content', title: 'Our Garden') }
  let!(:section) { create(:section, page: page_record, content_type: 'garden-content', section_name: 'garden-intro', image: nil, description: nil) }
  let!(:column) do
    create(:cell, section: section, section_name: 'garden-intro', cell_name: 'garden-intro_image', cell_type: 'image',
                  image: nil, link: nil, content: nil)
  end
  let!(:rose) { create(:image_file, name: 'rose', group: 'flowers', slide_order: 1) }
  let!(:tulip) { create(:image_file, name: 'tulip', group: 'flowers', slide_order: 2) }
  let!(:tour) { create(:image_file, name: 'garden-tour', group: nil, mime_type: 'video/mp4') }

  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
  end

  def open_image_tab
    visit admin_page_workspace_path(page_record, cell: column.id)
    within('.workspace-panel') { click_button 'Image' }
  end

  def choose_media(text)
    find('#column-media').click
    find('#column-media').send_keys(text.split.first)
    find('.column-media__option', text: text, exact_text: true).click
  end

  def saved_image = Cell.find(column.id).image

  def save_column
    wait_for_new_page { click_button 'Save Column' }
  end

  it 'lists pictures, slide shows with their sizes, and videos under their own headings' do
    open_image_tab
    find('#column-media').click
    expect(page).to have_css('.column-media__group-heading', text: /pictures/i)
    expect(page).to have_css('.column-media__group-heading', text: /slide shows/i)
    expect(page).to have_css('.column-media__group-heading', text: /videos/i)
    expect(page).to have_css('.column-media__option', text: 'flowers (2 pictures)')
    expect(page).to have_css('.column-media__option', text: 'garden-tour')
  end

  it 'stores a slide show, a video and a picture with the right reference' do
    open_image_tab
    choose_media 'flowers (2 pictures)'
    expect(page).to have_content('A slide show of the group flowers (2 pictures), in its slide order.')
    save_column
    expect(saved_image).to eq('ImageGroup:flowers')
    within('.workspace-panel') { click_button 'Image' } unless page.has_css?('#column-media', wait: 1)

    choose_media 'garden-tour'
    expect(page).to have_content('The video garden-tour, with play controls.')
    save_column
    expect(saved_image).to eq('VideoImage:"garden-tour"')
    within('.workspace-panel') { click_button 'Image' } unless page.has_css?('#column-media', wait: 1)

    choose_media 'tulip'
    expect(page).to have_content('The picture tulip.')
    save_column
    expect(saved_image).to eq('ImageFile:tulip')
    expect(Cell.find(column.id).formatting.to_h).not_to have_key('slide_show_images')
    within('.workspace-panel') { click_button 'Image' } unless page.has_css?('#column-media', wait: 1)

    within('.column-media') { expect(page).to have_text('tulip') }
    click_button 'Remove', exact: true
    save_column
    expect(saved_image).to be_nil
  end

  it 'shows the chosen slide show on the page' do
    column.update!(image: 'ImageGroup:flowers')
    visit admin_page_workspace_path(page_record, cell: column.id)
    within('.column-media') { expect(page).to have_text('flowers (2 pictures)') }
    expect(page).to have_content('A slide show of the group flowers')
  end
end
