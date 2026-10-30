require 'rails_helper'

RSpec.describe 'Create images while editing', type: :system do
  let!(:record) { create(:page) }
  let!(:section) { create(:section, page: record, content_type: record.section) }
  let!(:column) { create(:cell, section: section, content: '<p>Original content</p>', image: nil, link: nil) }

  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
  end

  def create_image_in_dialog(name)
    within_frame(find('iframe[title="New Image form"]')) do
      fill_in 'image_file[name]', with: name
      attach_file 'image_file[image]', Rails.root.join('spec/fixtures/files/sample.jpg')
      select 'JPEG', from: 'Mime Type'
      fill_in 'image_file[group]', with: 'New gallery'
      fill_in_quill_editor('image-file-caption', with: 'A caption')
      fill_in_quill_editor('image-file-description', with: 'An image description')
      page.save_screenshot(Rails.root.join('tmp/new-image-dialog.png'))
      click_button 'Save Image'
    end
    expect(page).to have_no_css('dialog[open]')
    expect(ImageFile.find_by!(name: name).image).to be_attached
  end

  it 'creates and selects an image without losing column edits, and cancels back to the same draft' do
    visit edit_admin_cell_path(column)
    enter_column_text 'Unsaved column content'
    click_button 'New Image'
    expect(page).to have_css('dialog[open]')
    create_image_in_dialog('Created from column')
    expect(page).to have_current_path(edit_admin_cell_path(column))
    expect(page).to have_css('.ql-editor', text: 'Unsaved column content')
    find('#image').click
    expect(page).to have_css('[role="option"]', text: 'Created from column')
    find('[role="option"]', text: 'Created from column', exact_text: true).click
    click_button 'New Image'
    within_frame(find('iframe')) do
      fill_in 'image_file[name]', with: 'Canceled image'
      click_link 'Cancel', exact: true
    end
    expect(page).to have_no_css('dialog[open]')
    expect(ImageFile.exists?(name: 'Canceled image')).to be(false)
    expect(page).to have_css('.ql-editor', text: 'Unsaved column content')
    click_button 'Save Column'
    expect(page).to have_current_path(admin_cells_path)
    expect(column.class.find(column.id).content).to include('Unsaved column content')
    expect(column.class.find(column.id).image).to include('Created from column')
  end

  it 'refreshes the generator image list and preserves the new page draft' do
    visit new_admin_page_path
    replace_react '#name', 'unsaved-page'
    replace_react '#section', 'Unsaved page section'
    click_button 'New Section'
    replace_react '#section_name', 'new-image-section'
    select 'Image Only', from: 'section_templates'
    click_button 'New Image'
    create_image_in_dialog('Created from generator')
    expect(page).to have_current_path(new_admin_page_path)
    expect(page).to have_select('section_templates', selected: 'Image Only')
    expect(page).to have_select(options: [ '-- Select an image --', 'Created from generator' ])
    find('select', text: '-- Select an image --').find(:option, 'Created from generator').select_option
    click_button 'Generate Sections'
    expect(find('#name').value).to eq('unsaved-page')
    expect(find('#section').value).to eq('Unsaved page section')
  end

  it 'keeps nested section edits when the image dialog is canceled' do
    visit edit_admin_section_path(section)
    replace_react '#section_order', '70'
    click_link 'Edit Column'
    enter_column_text 'Nested unsaved content'
    click_button 'New Image'
    within('dialog[open]') { click_button 'Cancel', exact: true }
    expect(page).to have_no_css('dialog[open]')
    expect(page).to have_css('.ql-editor', text: 'Nested unsaved content')
    click_button 'New Image'
    create_image_in_dialog('New nested image')
    click_button 'Save Column'
    click_link 'Edit Column'
    find('#image').click
    expect(page).to have_css('[role="option"]', text: 'New nested image')
    find('#image').send_keys(:escape)
    click_button 'Save Column'
    expect(find('#section_order').value).to eq('70')
    click_button 'Save Section'
    expect(page).to have_current_path(admin_sections_path)
    expect(section.class.find(section.id).section_order).to eq(70)
    expect(column.class.find(column.id).content).to include('Nested unsaved content')
  end
end
