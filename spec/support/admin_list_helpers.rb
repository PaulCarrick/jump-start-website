# The admin lists put View, History and Delete in a ⋯ menu on each row.
module AdminListHelpers
  # Opens the ⋯ menu of the row whose Edit link goes to edit_path, and
  # returns the row.
  def open_row_menu(edit_path)
    row = find(:xpath, "//tr[contains(@class, 'admin-list-record')][.//a[@href='#{edit_path}']]")
    row.find("button.admin-row-menu").click
    row
  end
end

RSpec.configure do |config|
  config.include AdminListHelpers, type: :system
end
