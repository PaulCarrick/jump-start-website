require 'rails_helper'

RSpec.describe "Admin Sections", type: :system do
  def search_sections(description)
    visit admin_sections_path

    expect(page).to have_field(name: 'q[description_cont]')
    fill_in "q[description_cont]", with: description
    click_button "Search Sections"
    expect(page).to have_current_path(/[?&]q(?:%5B|\[)/)
  end

  let(:admin_user) { create(:user, access: "super") }
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:page_record) { create(:page, section: "Test Content Type") }
  let!(:section) do
    create(:section, page: page_record, content_type: page_record.section,
           section_name: "Test Section Name", section_order: 1,
           description: "<p>Test Description</p>")
  end
  let!(:column) { create(:cell, section: section, content: "<p>Test Description</p>") }

  before do
    driven_by(:selenium_chrome_headless)
    login_as(admin_user)
  end

  describe "Index Page" do
    before { visit admin_sections_path }

    it "displays the correct title" do
      expect(page).to have_title("#{site_setup.site_name} - Admin Dashboard: Sections")
    end

    it "lists section metadata and rendered column content" do
      within '.auto-size' do
        expect(page).to have_content("Test Content Type")
        expect(page).to have_content("Test Section Name")
        expect(page).to have_content("Test Description")
      end
    end

    it "renders action links for each section" do
      expect(page).to have_link("View", href: admin_section_path(section))
      expect(page).to have_link("Edit", href: edit_admin_section_path(section))
      expect(page).to have_link("Delete", href: admin_destroy_section_path(section))
    end

    it "opens the section editor" do
      click_link "Edit", href: edit_admin_section_path(section)
      expect(page).to have_button("Save Section")
    end

    it "opens Add Section from the owning page" do
      visit edit_admin_page_path(page_record)
      click_link 'Add Section'
      expect(page).to have_current_path(%r{/admin/sections/\d+/edit}, ignore_query: true)
      expect(page).to have_select('cellTemplates')
    end
  end

  describe "New Section Page" do
    before { visit admin_add_section_to_existing_page_path(page_record) }

    it "has a CSRF token" do
      expect(page).to have_selector("meta[name='csrf-token']", visible: false)
    end

    it "displays the correct title" do
      expect(page).to have_title("#{site_setup.site_name} - Admin Dashboard: Sections")
    end

    it "offers column templates and content generation" do
      expect(page).to have_select('cellTemplates', with_options: [ 'Text Only', 'Image Only',
        'Dual Column - Text Left', 'Dual Column - Text Right', 'Three Column', 'Four Column', 'Five Column' ])
      select 'Text Only', from: 'cellTemplates'
      expect(page).to have_css('.ql-editor[contenteditable=true]')
      expect(page).to have_button('Generate Columns')
      expect(page).to have_content("Templates:")
    end

    it "generates columns and saves the new section under its page" do
      select 'Text Only', from: 'cellTemplates'
      enter_column_text 'New section column content'
      click_button 'Generate Columns'
      expect(page).to have_button('Save Section')
      click_button 'Save Section'
      expect(page).to have_current_path(edit_admin_page_path(page_record), ignore_query: true)
      expect(page).to have_content('New section column content')
      saved = page_record.sections.order(:id).last
      expect(saved.id).not_to eq(section.id)
      expect(saved.cells.first.content).to include('New section column content')
    end
  end

  describe "Edit Section Page" do
    before { visit edit_admin_section_path(section) }

    it "loads the section group and order" do
      section.update!(section_group: "Introduction")
      visit edit_admin_section_path(section)
      expect(page).to have_field("sectionGroup", with: "Introduction")
      expect(page).to have_field("section_order", with: "1")
    end

    it "saves and clears the section group" do
      visit edit_admin_section_path(section)
      fill_in "sectionGroup", with: "Introduction"
      click_button "Save Section"
      expect(section.reload.section_group).to eq("Introduction")

      visit edit_admin_section_path(section)
      fill_in "sectionGroup", with: ""
      click_button "Save Section"
      expect(section.reload.section_group).to eq("")
    end

    it "has a CSRF token" do
      expect(page).to have_selector("meta[name='csrf-token']", visible: false)
    end

    it "displays the correct title" do
      expect(page).to have_title("#{site_setup.site_name} - Admin Dashboard: Sections")
    end

    it "prefills metadata and offers column editing" do
      expect(find("#sectionNameDiv")).to have_content("Test Section Name")
      expect(page).to have_css('#section_order[value="1"]')
      expect(page).to have_content('Test Description')
      expect(page).to have_link('Edit Column')
      expect(page).to have_button('Save Section')
    end

    it "persists the section name and order" do
      replace_react '#section_name', 'Updated Section Name'
      replace_react '#section_order', '3'
      click_button 'Save Section'
      expect(page).to have_current_path(admin_sections_path, ignore_query: true)
      expect(page).to have_content('Updated Section Name')
      expect(section.reload.section_order).to eq(3)
      expect(section.cells.first.content).to include('Test Description')
    end
  end

  describe "Show Section Page" do
    before { visit admin_section_path(section) }

    it "displays the correct title" do
      expect(page).to have_title("#{site_setup.site_name} - Admin Dashboard: Sections")
    end

    it "shows the section metadata and rendered column" do
      expect(page).to have_content('Test Content Type')
      expect(page).to have_content('Test Section Name')
      expect(page).to have_content('Test Description')
    end
  end
end
