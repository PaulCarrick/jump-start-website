# The links at the foot of the admin sidebar (Help, Video Tutorial, New Site Tutorial)
# now come from "Help" menu items instead of the code. Existing sites get the same
# three items the seed gives a new site. A site that already has Help items keeps them.
class AddHelpMenuItems < ActiveRecord::Migration[8.1]
  ITEMS = [
    { label: "Help", link: "/admin/help", menu_order: 1 },
    { label: "Video Tutorial", link: "/tutorial/jump-start-website-tutorial.mp4", menu_order: 2 },
    { label: "New Site Tutorial", link: "/admin/tutorial", menu_order: 3 }
  ].freeze

  def up
    return if select_value("SELECT 1 FROM menu_items WHERE menu_type = 'Help' LIMIT 1")

    MenuItem.reset_column_information
    ITEMS.each do |item|
      MenuItem.create!(item.merge(menu_type: "Help", enabled: true, icon: "", options: "", access: ""))
    end
  end

  def down
    execute "DELETE FROM menu_items WHERE menu_type = 'Help'"
  end
end
