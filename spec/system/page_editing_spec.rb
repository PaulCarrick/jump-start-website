require 'rails_helper'

RSpec.describe 'Editing a page from the public site', type: :system do
  let(:admin_user) { create(:user, access: 'super') }
  let!(:page_record) { create(:page, name: 'garden', section: 'garden-content', title: 'Garden') }
  let!(:section) { create(:section, page: page_record, content_type: 'garden-content', section_name: 'garden-intro') }
  let!(:image) { create(:image_file, name: 'rose-picture') }
  let!(:picture_column) do
    create(:cell, section: section, section_name: 'garden-intro', cell_type: 'image', cell_order: 1, width: '50%',
                  image: 'ImageFile:rose-picture', link: nil, content: nil)
  end
  let!(:text_column) do
    create(:cell, section: section, section_name: 'garden-intro', cell_type: 'text', cell_order: 2, width: '50%',
                  image: nil, link: nil, content: '<p>Roses in bloom</p>')
  end

  before do
    driven_by(:selenium_chrome_headless)
    login_as(admin_user)
  end

  # The editor opens in a new tab; record where instead.
  def capture_opened_tabs
    page.execute_script("window.openedTabs = []; window.open = (url) => { window.openedTabs.push(url); return null; };")
  end

  def right_click_and_edit(element, label)
    element.right_click
    expect(page).to have_css('.page-edit-menu-item', text: label)
    find('.page-edit-menu-item', text: label).click
    page.evaluate_script('window.openedTabs[window.openedTabs.length - 1]')
  end

  it 'turns Edit Page into Save Changes and Cancel, and offers Edit on right-click' do
    visit page_path('garden')
    click_button 'Edit Page'
    expect(page).to have_button(text: /Editing…\s+Save Changes/)
    expect(page).to have_button('Cancel')
    expect(page).to have_content('Roses in bloom')
    capture_opened_tabs

    expect(right_click_and_edit(find('#contents img', match: :first), 'Edit image')).to include('/admin/image_files/locate?src=')
    expect(right_click_and_edit(find('p', text: 'Roses in bloom'), 'Edit column'))
      .to eq(admin_page_workspace_path(page_record, cell: text_column.id))
    expect(right_click_and_edit(find('.page-edit-hint', match: :first), 'Edit page')).to eq(admin_page_workspace_path(page_record))
  end

  it 'leaves the page as it was on Cancel' do
    visit page_path('garden')
    click_button 'Edit Page'
    expect(page).to have_button('Cancel')
    click_button 'Cancel'
    expect(page).to have_button('Edit Page')
    expect(page).to have_content('Nothing to discard.')
  end
end
