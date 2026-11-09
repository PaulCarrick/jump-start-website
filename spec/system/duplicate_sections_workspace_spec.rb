require 'rails_helper'

RSpec.describe 'Duplicating sections from the workspace and the page itself', type: :system do
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:page_record) { create(:page, name: 'garden', section: 'garden-content', title: 'Our Garden') }
  let!(:roses) do
    create(:section, page: page_record, content_type: 'garden-content', section_name: 'roses', section_group: 'flowers',
                     section_order: 10, image: nil, description: nil)
  end
  let!(:tulips) do
    create(:section, page: page_record, content_type: 'garden-content', section_name: 'tulips', section_group: 'flowers',
                     section_order: 20, image: nil, description: nil)
  end
  let!(:herbs) do
    create(:section, page: page_record, content_type: 'garden-content', section_name: 'herbs', section_order: 30, image: nil, description: nil)
  end

  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
    create(:cell, section: roses, section_name: 'roses', cell_name: 'roses_text', image: nil, link: nil, content: '<p>Roses in bloom</p>')
    create(:cell, section: tulips, section_name: 'tulips', cell_name: 'tulips_text', image: nil, link: nil, content: '<p>Tulips in spring</p>')
    create(:cell, section: herbs, section_name: 'herbs', cell_name: 'herbs_text', image: nil, link: nil, content: '<p>Herbs by the door</p>')
  end

  def page_order = Section.where(page_id: page_record.id).order(:section_order).pluck(:section_name)

  it 'copies a whole group to the end under a new name, then renames the copies' do
    visit admin_page_workspace_path(page_record, section: tulips.id)
    within('.workspace-panel') do
      fill_in 'Name for a copy of the whole group (2 sections)', with: 'bulbs'
      wait_for_new_page { click_button 'Duplicate group' }
    end
    expect(page).to have_content('Group duplicated as bulbs: bulbs-roses, bulbs-tulips')
    expect(page_order).to eq(%w[roses tulips herbs bulbs-roses bulbs-tulips])

    within('.workspace-panel') do
      fill_in 'rename-group-' + Section.find_by!(section_name: 'bulbs-roses').id.to_s, with: 'spring'
      fill_in "rename-section-#{Section.find_by!(section_name: 'bulbs-roses').id}", with: 'spring-roses'
      fill_in "rename-section-#{Section.find_by!(section_name: 'bulbs-tulips').id}", with: 'spring-tulips'
      wait_for_new_page { click_button 'Save names' }
    end
    expect(page).to have_content('Group renamed to spring.')
    expect(Section.where(section_group: 'spring').order(:section_order).pluck(:section_name)).to eq(%w[spring-roses spring-tulips])
  end

  it 'copies one section of a group on its own' do
    visit admin_page_workspace_path(page_record, section: tulips.id)
    within('.workspace-panel') do
      fill_in 'Name for the copy of this section', with: 'more-tulips'
      wait_for_new_page { click_button 'Duplicate section' }
    end
    expect(page).to have_content('Section duplicated as more-tulips, at the end of the page.')
    expect(page_order.last).to eq('more-tulips')
    expect(Section.find_by!(section_name: 'more-tulips').section_group).to be_nil
  end

  it 'copies a group from the page itself with a right-click, and asks for the name' do
    visit page_path('garden')
    click_button 'Edit Page'
    expect(page).to have_button(text: /Editing…\s+Save Changes/)
    find("[data-section-id='#{roses.id}']", match: :first).right_click
    expect(page).to have_css('.page-edit-menu-item', text: 'Duplicate section…')
    find('.page-edit-menu-item', text: 'Duplicate group “flowers”…').click
    within('dialog.page-edit-dialog') do
      expect(page).to have_content('2 sections, named flowers-copy-roses, flowers-copy-tulips')
      find('input').fill_in(with: 'bulbs')
      expect(page).to have_content('named bulbs-roses, bulbs-tulips')
      click_button 'Duplicate'
    end
    expect(page).to have_css('.page-edit-moving', text: 'Group duplicated as bulbs')
    expect(page).to have_text(/Herbs by the door.*Roses in bloom.*Tulips in spring/m)
    expect(page_order).to eq(%w[roses tulips herbs bulbs-roses bulbs-tulips])
    expect(page).to have_button(text: /Save Changes \(\d+\)/)
  end

  it 'shows a refused name in the box and copies nothing' do
    visit page_path('garden')
    click_button 'Edit Page'
    find("[data-section-id='#{herbs.id}']", match: :first).right_click
    find('.page-edit-menu-item', text: 'Duplicate section…').click
    expect(page).to have_no_css('.page-edit-menu-item', text: /Duplicate group/)
    within('dialog.page-edit-dialog') do
      find('input').fill_in(with: 'roses')
      click_button 'Duplicate'
      expect(page).to have_css('.page-edit-dialog-error', text: 'already used')
    end
    expect(page_order).to eq(%w[roses tulips herbs])
  end
end
