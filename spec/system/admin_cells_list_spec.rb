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
  it 'creates a draft column from the New Column button using its selected section' do
    section = create(:section, section_name: 'new-column-parent')
    visit admin_cells_path
    expect(page).to have_css('h1', text: 'Manage Columns')
    expect(page).to have_link('Columns', href: admin_cells_path)
    expect(page).to have_button('Search Columns')
    expect(page).to have_title(/Admin Dashboard: Columns/)
    click_link 'New Column'
    expect(page).to have_css('h1', text: 'New Column')
    find('#sectionNameDiv input[role="combobox"]').set(section.section_name)
    find('[role="option"]', text: section.section_name, exact_text: true).click
    replace_react('#cell_name', 'Created from Manage Columns')
    enter_column_text 'New column content'
    click_button 'Save Column'
    expect(page).to have_current_path(admin_cells_path, ignore_query: true)
    saved = Cell.pending_versions.find_by!(cell_name: 'Created from Manage Columns')
    expect(saved.section_id).to eq(section.id)
    expect(saved.content).to include('New column content')
    expect(Cell.live_versions.where(id: saved.id)).not_to exist
  end
end
