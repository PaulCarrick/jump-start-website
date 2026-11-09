# Where the site's menu sits: along the top (as before), as a sidebar on the
# left or right, or as a bar along the bottom. Every existing setup, and every
# earlier version of it, gets "top", so nothing changes until it is chosen.
class AddMenuPositionToSiteSetups < ActiveRecord::Migration[8.1]
  def up
    execute "SET LOCAL lock_timeout = '10s'"
    add_column :site_setups, :menu_position, :string, default: 'top', null: false
    add_column :site_setups_history, :menu_position, :string, default: 'top', null: false
    rebuild_history_hook
  end

  def down
    execute "SET LOCAL lock_timeout = '10s'"
    drop_versioning_hook :site_setups, :site_setups_history, primary_key: [ :id, :version ]
    remove_column :site_setups, :menu_position
    remove_column :site_setups_history, :menu_position
    create_versioning_hook :site_setups, :site_setups_history, primary_key: [ :id, :version ]
  end

  private

  def rebuild_history_hook
    # The history hooks list the columns, so they are made again to record the new one.
    drop_versioning_hook :site_setups, :site_setups_history, primary_key: [ :id, :version ]
    create_versioning_hook :site_setups, :site_setups_history, primary_key: [ :id, :version ]
  end
end
