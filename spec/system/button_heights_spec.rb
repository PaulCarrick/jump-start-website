require 'rails_helper'

RSpec.describe 'Consistent action button heights', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    page.driver.browser.manage.window.resize_to(1400, 1000)
    login_as(create(:user, access: 'super'))
  end

  def expect_uniform_buttons
    heights = page.evaluate_script(<<~JS)
      Array.from(document.querySelectorAll('.btn')).filter(button =>
        button.getClientRects().length && getComputedStyle(button).visibility !== 'hidden'
      ).map(button => ({text: button.textContent.trim() || button.value, height: button.getBoundingClientRect().height}));
    JS
    expect(heights).not_to be_empty
    expect(heights.select { |button| (button['height'] - 44).abs > 0.5 }).to eq([])
  end

  it 'matches image links, group buttons, form submits, sorting and disabled pagination' do
    image = create(:image_file)
    visit admin_image_files_path
    expect(page).to have_link('New Image')
    expect(page).to have_button('Upload', disabled: true)
    expect(page).to have_button('Search')
    expect(page).to have_css('.btn.disabled')
    expect_uniform_buttons
    page.driver.browser.manage.window.resize_to(390, 844)
    expect_uniform_buttons
    visit edit_admin_image_file_path(image)
    expect(page).to have_button('Save Image')
    expect_uniform_buttons
  end

  it 'matches React editor actions, formatting toggles and image picker actions' do
    cell = create(:cell, image: nil, link: nil)
    visit edit_admin_cell_path(cell)
    expect(page).to have_button('New Image')
    expect(page).to have_button('Save Column')
    expect_uniform_buttons
    click_button 'Switch to Formatting Mode'
    expect_uniform_buttons
    click_button 'New Image'
    expect(page).to have_css('dialog[open]')
    expect_uniform_buttons
    within_frame(find('iframe[title="New Image form"]')) do
      expect(page).to have_button('Add to Group')
      expect_uniform_buttons
    end
  end

  it 'keeps public link-style expansion buttons the same height' do
    record = create(:page)
    section = create(:section, page: record, content_type: record.section)
    create(:cell, section: section, image: nil, link: nil,
           content: '<p>Expandable text</p>', formatting: { expanding_cells: 'toggle, .extra-details, btn btn-link p-0' })
    visit page_path(record.name)
    expect(page).to have_button('Show More')
    expect_uniform_buttons
  end
end
