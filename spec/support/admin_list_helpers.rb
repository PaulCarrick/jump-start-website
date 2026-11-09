# The admin lists put View, History and Delete in a ⋯ menu on each row.
module AdminListHelpers
  # Opens the ⋯ menu of the row whose Edit link goes to edit_path, and
  # returns the row.
  def open_row_menu(edit_path)
    row = find(:xpath, "//tr[contains(@class, 'admin-list-record')][.//a[@href='#{edit_path}']]")
    row.find("button.admin-row-menu").click
    row
  end

  # Runs the block (a click that reloads the page) and waits for the new page,
  # even when its address is the same as the old one.
  def wait_for_new_page
    page.execute_script("document.documentElement.dataset.oldPage = 'true'")
    yield
    expect(page).to have_no_css("html[data-old-page]")
  end
end

RSpec.configure do |config|
  config.include AdminListHelpers, type: :system
end
