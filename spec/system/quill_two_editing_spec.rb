require 'rails_helper'

# Quill 2 keeps its own list markup inside the editor; what the site stores must
# still be ordinary HTML (<ul>, plain spaces) that public pages display correctly.
RSpec.describe 'Editing text with Quill 2', type: :system do
  let(:admin_user) { create(:user, access: 'super') }

  before do
    driven_by(:selenium_chrome_headless)
    page.driver.browser.manage.window.resize_to(1400, 1000)
    login_as(admin_user)
  end

  it 'loads existing content and saves ordinary HTML lists and spaces' do
    record = create(:page)
    section = create(:section, page: record, content_type: record.section)
    cell = create(:cell, section: section, image: nil, link: nil, cell_type: 'text',
                  content: '<p>One two three</p><ul><li>First item</li><li>Second item</li></ul>')

    visit edit_admin_cell_path(cell)
    editor = find('.ql-editor[contenteditable=true]', match: :first)
    expect(editor).to have_css('li', count: 2)
    expect(editor).to have_text('One two three')

    editor.click
    editor.send_keys([ :command, :end ], [ :control, :end ], ' Added words')
    click_button 'Save Column'
    expect(page).to have_current_path(admin_cells_path, ignore_query: true)

    saved = Cell.unscoped.where(id: cell.id).order(:version).last.content
    expect(saved).to include('<ul>', 'First item', 'Second item', 'One two three', 'Added words')
    expect(saved).not_to include('data-list', '&nbsp;')
  end

  it 'shows bullets and numbers for saved lists on public pages' do
    record = create(:page)
    section = create(:section, page: record, content_type: record.section)
    create(:cell, section: section, image: nil, link: nil, cell_type: 'text',
           content: '<ul><li>Bulleted</li></ul><ol><li>Numbered</li></ol>')

    visit page_path(record.name)
    expect(page).to have_css('.rich-text-content li', text: 'Bulleted')
    expect(page.evaluate_script("getComputedStyle(document.querySelector('.rich-text-content ul > li')).listStyleType")).to eq('disc')
    expect(page.evaluate_script("getComputedStyle(document.querySelector('.rich-text-content ol > li')).listStyleType")).to eq('decimal')
  end
end
