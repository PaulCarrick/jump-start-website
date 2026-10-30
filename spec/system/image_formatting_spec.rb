require 'rails_helper'

RSpec.describe 'Image formatting in columns', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
  end

  it 'previews image classes and CSS and saves them in the column draft' do
    image = create(:image_file)
    cell = create(:cell, cell_type: 'image', image: "ImageFile:#{image.name}", link: nil,
                  formatting: { classes: 'col-lg-7 mb-3' })
    visit edit_admin_cell_path(cell)
    expect(page).to have_field('Image Styles:', with: '')
    find_field('Image Classes:').send_keys('rounded shadow')
    fill_in 'Image Styles:', with: ''
    find_field('Image Styles:').send_keys('max-width: 400px; border-radius: 12px;')
    expect(page).to have_css('#cellPreview img.img-fluid.rounded.shadow[style*="max-width: 400px"][style*="border-radius: 12px"]')
    click_button 'Save Column'
    expect(page).to have_current_path(admin_cells_path, ignore_query: true)
    expect(Cell.find(cell.id).formatting['image_classes']).to eq('rounded shadow')
    expect(Cell.find(cell.id).formatting['image_styles']).to eq('max-width: 400px; border-radius: 12px;')
  end
  it 'accepts typing when the column editor is opened inside a section' do
    image = create(:image_file)
    section = create(:section)
    create(:cell, section: section, cell_type: 'image', image: "ImageFile:#{image.name}", link: nil)
    visit edit_admin_section_path(section)
    click_link 'Edit Column'
    find_field('Image Classes:').send_keys('rounded shadow')
    find_field('Image Styles:').send_keys('border-radius: 12px;')
    expect(page).to have_field('Image Classes:', with: 'rounded shadow')
    expect(page).to have_field('Image Styles:', with: 'border-radius: 12px;')
  end

end
