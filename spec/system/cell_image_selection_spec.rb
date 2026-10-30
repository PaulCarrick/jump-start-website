require 'rails_helper'

RSpec.describe 'Cell image selection', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
  end

  it 'restores the saved choice and persists image removal without deleting the file' do
    image = create(:image_file)
    cell = create(:cell, cell_type: 'image', image: "ImageFile:#{image.name}", link: nil)
    visit edit_admin_cell_path(cell)
    within('#imageDiv') { expect(page).to have_text(image.name) }
    expect(page).to have_content("Current image: #{image.name}")
    click_button 'Remove Image'
    expect(page).to have_no_css('#cellPreview img')
    click_button 'Save Column'
    expect(page).to have_current_path(admin_cells_path, ignore_query: true)
    expect(Cell.find(cell.id).image).to be_nil
    visit edit_admin_cell_path(cell)
    expect(page).to have_no_button('Remove Image')
    expect(page).to have_no_css('#cellPreview img')
    expect(ImageFile.find(image.id).image).to be_attached
    PublishingContext.live = true
    expect(Cell.find(cell.id).image).to eq("ImageFile:#{image.name}")
  end

  it 'allows replacing the saved image and restores the replacement on reopening' do
    image = create(:image_file)
    replacement = create(:image_file)
    cell = create(:cell, cell_type: 'image', image: "ImageFile:#{image.name}", link: nil)
    visit edit_admin_cell_path(cell)
    find('#image').send_keys(replacement.name)
    within('#imageDiv') { find('[role=option]', text: replacement.name, exact_text: true).click }
    click_button 'Save Column'
    expect(page).to have_current_path(admin_cells_path, ignore_query: true)
    expect(Cell.find(cell.id).image).to eq("ImageFile:#{replacement.name}")
    visit edit_admin_cell_path(cell)
    within('#imageDiv') { expect(page).to have_text(replacement.name) }
  end
end
