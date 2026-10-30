require "rails_helper"

RSpec.describe "Returning from admin editors", type: :system do
  let!(:record) { create(:page) }
  let!(:section) { create(:section, page: record, content_type: record.section) }
  let!(:column) { create(:cell, section: section, content: '<p>Original column</p>', image: nil, link: nil) }

  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
    visit admin_pages_path
    click_link 'Edit', href: edit_admin_page_path(record)
  end

  def expect_page_section
    expect(page).to have_current_path(edit_admin_page_path(record), ignore_query: true)
    expect(URI.decode_www_form(URI.parse(page.current_url).query.to_s).to_h['section_name']).to eq(section.section_name)
  end

  it "saves and cancels a column back to its section on the page, then saves the page to its index" do
    click_link 'Edit Column'
    enter_column_text 'Changed directly from page'
    click_button 'Save Column'
    expect_page_section
    expect(page).to have_content('Changed directly from page')
    expect(column.class.find(column.id).content).to include('Changed directly from page')
    click_link 'Edit Column'
    enter_column_text 'Unsaved column'
    click_button 'Cancel'
    expect_page_section
    expect(column.class.find(column.id).content).not_to include('Unsaved column')
    click_button 'Save Page'
    expect(page).to have_current_path(admin_pages_path)
  end

  it "returns an embedded column to its section editor and the section to its calling page" do
    click_link 'Edit Section'
    expect(page).to have_button('Save Section')
    click_link 'Edit Column'
    enter_column_text 'Nested column change'
    click_button 'Save Column'
    expect(page).to have_button('Save Section')
    expect(page).to have_content('Nested column change')
    click_button 'Save Section'
    expect_page_section
    expect(column.class.find(column.id).content).to include('Nested column change')
    click_link 'Edit Section'
    click_link 'Edit Column'
    click_button 'Cancel'
    expect(page).to have_button('Save Section')
    click_button 'Cancel'
    expect_page_section
    click_link 'Cancel', exact: true
    expect(page).to have_current_path(admin_pages_path)
  end

  it "cancels a newly added section back to its page and preserves the page caller" do
    click_link 'Add Section'
    expect(page).to have_select('cellTemplates')
    added = record.sections.order(:id).last
    expect(added.id).not_to eq(section.id)
    click_button 'Cancel'
    expect(page).to have_current_path(edit_admin_page_path(record), ignore_query: true)
    expect(Section.exists?(added.id)).to be(false)
    click_link 'Cancel', exact: true
    expect(page).to have_current_path(admin_pages_path)
  end

  it "uses the sidebar index when opening an editor there" do
    within('#navbarNav') { click_link 'Sections', exact: false }
    expect(page).to have_current_path(admin_sections_path)
    click_link 'Edit', href: edit_admin_section_path(section)
    click_button 'Cancel'
    expect(page).to have_current_path(admin_sections_path)
    click_link 'Edit', href: edit_admin_section_path(section)
    click_button 'Save Section'
    expect(page).to have_current_path(admin_sections_path)
  end
end
