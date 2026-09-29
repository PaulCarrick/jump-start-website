require 'rails_helper'

# A single, continuous walk through the admin tool end to end: create a page,
# add one Section per layout the "Generate Columns" screen actually offers
# (GenerateCells.tsx's selectCellTemplates - Text Only, Image Only, both Dual
# Column layouts, and Three/Four/Five Column), edit a Section and a Cell,
# delete a Section, add an Image File / Menu Item / Footer Item, then visit
# the page on the live site and confirm everything is really there.
#
# This is deliberately ONE example, not several smaller `it`s: rails_helper.rb
# runs `db:replicate` (a real pg_dump/restore of the dev database) before
# EVERY `type: :system` example, so anything a prior example created would
# already be gone - replaced by a fresh copy of dev data - before the next
# example ran. Splitting this into multiple `it`s that depend on each other's
# state would not work with that setup.
#
# Because db:replicate also means this runs against a full copy of Paul's
# real dev data (not a truly empty database), every record this spec creates
# carries a random suffix so nothing here can collide with, or be confused
# for, real content.
RSpec.describe "Admin Full Workflow", type: :system do
  let(:admin_user) { create(:user, access: "super") }
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }

  before do
    if ENV["DEBUG"].present? || ENV["RSPEC_DEBUG"].present?
      driven_by(:selenium_chrome)
    else
      driven_by(:selenium_chrome_headless)
    end

    login_as(admin_user)
  end

  # _page_form.erb's "Delete Section" link carries both a Rails UJS
  # data-confirm AND a redundant inline onclick confirm() - in practice that
  # can surface one native alert or two in a row depending on the browser, so
  # accept whatever actually shows up instead of assuming exactly one.
  def accept_up_to(count)
    count.times do
      begin
        page.driver.browser.switch_to.alert.accept
      rescue Selenium::WebDriver::Error::NoSuchAlertError
        break
      end
    end
  end

  it "creates a page with every section layout, edits and deletes content, adds an image/menu item/footer item, and renders it all on the live site" do
    run_id       = SecureRandom.hex(4)
    page_name    = "e2e-test-page-#{run_id}"
    section_name = "e2e-test-section-#{run_id}"
    image_name   = "e2e-test-image-#{run_id}"
    menu_label   = "E2E Test Menu #{run_id}"
    footer_label = "E2E Test Footer #{run_id}"

    # -----------------------------------------------------------------
    # 1. Create a new Page
    # -----------------------------------------------------------------
    visit new_admin_page_path

    fill_in "name", with: page_name
    fill_in "section_name", with: section_name
    fill_in "title", with: "E2E Test Page #{run_id}"
    fill_in "access", with: "Public"
    click_button "Save Page"

    expect(page).to have_current_path(admin_pages_path)
    expect(page).to have_content(page_name)

    page_record = Page.find_by!(name: page_name)

    # -----------------------------------------------------------------
    # 2. Add an Image File - needed for the image-based layouts below,
    #    and exercises "add images" in its own right.
    # -----------------------------------------------------------------
    visit new_admin_image_file_path

    fill_in "image_file[name]", with: image_name
    attach_file "image_file[image]", Rails.root.join("spec/fixtures/files/sample.jpg")
    select "JPEG", from: "Mime Type"
    fill_in "image_file[group]", with: "e2e-test-group-#{run_id}"
    fill_in "image_file[slide_order]", with: 1
    fill_in_quill_editor("image-file-caption", with: "E2E Test Caption #{run_id}")
    fill_in_quill_editor("image-file-description", with: "E2E Test Description #{run_id}")
    click_button "Save Image"

    expect(page).to have_current_path(admin_image_files_path(turbo: false))
    expect(page).to have_content(image_name)
    expect(ImageFile.find_by(name: image_name)).to be_present

    # -----------------------------------------------------------------
    # 3. Add one Section per layout. add_section_to_page always creates a
    #    blank Section and redirects straight to its Generate Columns
    #    screen; from there we pick a layout, fill in whatever it needs,
    #    generate the columns, then name/order and save the section.
    # -----------------------------------------------------------------
    layouts = [
      { label: "Text Only",                needs_content: true,  needs_image: false },
      { label: "Image Only",               needs_content: false, needs_image: true },
      { label: "Dual Column - Text Left",  needs_content: true,  needs_image: true },
      { label: "Dual Column - Text Right", needs_content: true,  needs_image: true },
      { label: "Three Column",             needs_content: false, needs_image: false },
      { label: "Four Column",              needs_content: false, needs_image: false },
      { label: "Five Column",              needs_content: false, needs_image: false }
    ]

    section_names_by_index = {}

    layouts.each_with_index do |layout, index|
      visit admin_add_section_to_existing_page_path(page_record)

      expect(page).to have_selector("#GenerateCells")

      select layout[:label], from: "cellTemplates"

      fill_in_quill_editor("content", with: "E2E content for #{layout[:label]} (#{run_id}).") if layout[:needs_content]

      if layout[:needs_image]
        # RenderImageControl.tsx renders a plain <select> with no id/name of
        # its own, just an "Image:" label in the sibling column, so it has
        # to be located by that text rather than by field name.
        find(:xpath, "//div[text()='Image:']/following-sibling::div[1]//select").select(image_name)
      end

      click_button "Generate Columns"

      # Generating columns switches SectionEditor over to its
      # section_name/section_order editor.
      expect(page).to have_field("section_name")

      this_section_name = "#{section_name}-#{index}"
      section_names_by_index[index] = this_section_name

      find("#section_name").set(this_section_name)
      find("#section_order").set((index + 1).to_s)
      click_button "Save Section"

      # add_section_to_page redirects here with return_url set to
      # edit_admin_page_path(page), and Save Section now honors that
      # (options.returnUrl was previously never wired up - see
      # _section_form.erb).
      expect(page).to have_current_path(edit_admin_page_path(page_record), ignore_query: true)

      created_section = Section.find_by!(section_name: this_section_name)

      expect(created_section.cells.count).to be >= 1
    end

    expect(page_record.sections.reload.count).to eq(layouts.count)

    # -----------------------------------------------------------------
    # 4. Edit a Section directly (the "Text Only" one) - name and order
    #    only, so its cell content is left alone for the front-end check
    #    later.
    # -----------------------------------------------------------------
    text_only_section = Section.find_by!(section_name: section_names_by_index[0])
    updated_section_name = "#{section_names_by_index[0]}-updated"

    visit edit_admin_section_path(text_only_section)

    find("#section_name").set(updated_section_name)
    find("#section_order").set("99")
    click_button "Save Section"

    # No return_url was passed this time, so Save Section falls back to the
    # section's own Show page.
    expect(page).to have_current_path(admin_section_path(text_only_section))

    expect(text_only_section.reload.section_name).to eq(updated_section_name)
    expect(text_only_section.section_order).to eq(99)

    # -----------------------------------------------------------------
    # 5. Edit a Cell directly. SectionEditor's own inline "Edit Column"
    #    link never shows (RenderSection is always called there with
    #    editing={false}), so this goes through the standalone Cell edit
    #    screen, which is a real, working path in its own right.
    # -----------------------------------------------------------------
    text_right_section = Section.find_by!(section_name: section_names_by_index[3])
    cell_to_edit        = text_right_section.cells.find { |cell| cell.content.present? }
    updated_cell_name    = "e2e-test-cell-#{run_id}-updated"
    updated_cell_content = "Updated E2E cell content (#{run_id})."

    visit edit_admin_cell_path(cell_to_edit)

    find("#cell_name").set(updated_cell_name)
    fill_in_quill_editor("content", with: updated_cell_content)
    click_button "Save Column"

    expect(page).to have_current_path(admin_cell_path(cell_to_edit))

    expect(cell_to_edit.reload.cell_name).to eq(updated_cell_name)
    expect(cell_to_edit.content).to include("Updated E2E cell content")

    # -----------------------------------------------------------------
    # 6. Delete a Section (the "Dual Column - Text Left" one) from the
    #    Edit Page screen.
    # -----------------------------------------------------------------
    section_to_delete = Section.find_by!(section_name: section_names_by_index[2])

    visit edit_admin_page_path(page_record)

    within("##{section_to_delete.section_name}") do
      click_link "Delete Section"
    end

    accept_up_to(2)

    expect(Section.exists?(section_to_delete.id)).to be(false)
    expect(page_record.sections.reload.count).to eq(layouts.count - 1)

    # -----------------------------------------------------------------
    # 7. Add a Menu Item
    # -----------------------------------------------------------------
    visit new_admin_menu_item_path

    fill_in "menu_item[label]", with: menu_label
    select "Main", from: "menu_item[menu_type]"
    fill_in "menu_item[menu_order]", with: 99
    click_button "Save Menu Item"

    expect(page).to have_current_path(admin_menu_items_path(turbo: false))
    expect(page).to have_content("Menu Item created successfully.")
    expect(MenuItem.find_by(label: menu_label)).to be_present

    # -----------------------------------------------------------------
    # 8. Add a Footer Item
    # -----------------------------------------------------------------
    visit new_admin_footer_item_path

    fill_in "footer_item[label]", with: footer_label
    fill_in "footer_item[link]", with: "https://example.com/e2e-#{run_id}"
    fill_in "footer_item[footer_order]", with: 99
    click_button "Save Footer Item"

    expect(page).to have_current_path(admin_footer_items_path(turbo: false))
    expect(page).to have_content("Footer Item created successfully.")
    expect(FooterItem.find_by(label: footer_label)).to be_present

    # -----------------------------------------------------------------
    # 9. Walk through the new page on the live site. This is the page we
    #    just built (page_path(page_record.name)) - not Paul's real "home"
    #    page (root_path redirects to page_path("home"), a real page from
    #    his dev data that this spec has no business touching).
    # -----------------------------------------------------------------
    visit page_path(page_record.name)

    # Text Only: untouched by the section-level edit in step 4.
    expect(page).to have_content("E2E content for Text Only")

    # Dual Column - Text Right: its cell content was overwritten in step 5.
    expect(page).to have_content(updated_cell_content)

    # Three/Four/Five Column: auto-generated placeholder cells, none of
    # which were touched or deleted.
    expect(page).to have_content("Text for First Cell.")
    expect(page).to have_content("Text for Fourth Cell.")
    expect(page).to have_content("Text for Fifth Cell.")

    # Image Only / Dual Column - Text Right both use the image we uploaded.
    expect(page).to have_css("img.img-fluid")

    # Dual Column - Text Left was deleted in step 6 - its content must be
    # gone from the live page.
    expect(page).not_to have_content("E2E content for Dual Column - Text Left")
  end
end
