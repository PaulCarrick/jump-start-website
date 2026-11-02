class AddDatabaseToSiteSetups < ActiveRecord::Migration[8.1]
  def up
    execute "SET LOCAL lock_timeout = '10s'"
    # Add to both native temporal tables. PostgreSQL's constant default also
    # backfills all existing live, pending, and historical versions.
    add_column :site_setups, :database, :string, default: 'paul-carrick', null: false
    add_column :site_setups_history, :database, :string, default: 'paul-carrick', null: false
    rebuild_history_hook
  end

  def down
    execute "SET LOCAL lock_timeout = '10s'"
    drop_versioning_hook :site_setups, :site_setups_history, primary_key: [ :id, :version ]
    remove_column :site_setups, :database
    remove_column :site_setups_history, :database
    create_versioning_hook :site_setups, :site_setups_history, primary_key: [ :id, :version ]
  end

  private

  def rebuild_history_hook
    # Hooks enumerate columns, so regenerate them to record future changes.
    drop_versioning_hook :site_setups, :site_setups_history, primary_key: [ :id, :version ]
    create_versioning_hook :site_setups, :site_setups_history, primary_key: [ :id, :version ]
  end
end
