require 'rails_helper'

RSpec.describe 'Admin Cells list', type: :system do
  let(:admin_user) { create(:user, access: 'super') }
  let!(:cells) do
    create_list(:cell, 6, section_name: 'list-preview-check', image: nil, link: nil,
      content: '<p>Wrapping preview text</p><img src="/icon.png" style="width: 2400px; height: 1200px">')
  end

  before do
    driven_by(:selenium_chrome_headless)
    login_as(admin_user)
  end

  it 'shows five rows with constrained previews and paginates the remaining cell' do
    visit admin_cells_path(q: { section_name_cont: 'list-preview-check' })
    expect(page).to have_css('.admin-cell-record', count: 5)
    expect(page).to have_css('.admin-cell-preview', text: 'Wrapping preview text', count: 5)
    expect(page).to have_css('.admin-cell-preview img', count: 5)
    expect(page.evaluate_script(<<~JS)).to be(true)
      Array.from(document.querySelectorAll('.admin-cell-preview')).every(preview => {
        const image = preview.querySelector('img');
        return image.getBoundingClientRect().width <= preview.getBoundingClientRect().width &&
          preview.scrollWidth <= preview.clientWidth;
      })
    JS
    within('.admin-cells-table tbody tr:first-child') do
      expect(page).to have_link('View')
      expect(page).to have_link('Edit')
      expect(page).to have_link('Delete')
    end
    first('a', text: 'Next', exact_text: true).click
    expect(page).to have_css('.admin-cell-record', count: 1)
  end
end
