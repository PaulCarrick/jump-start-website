class AddSiteDatabaseProvisioning < ActiveRecord::Migration[8.1]
  def up
    create_table :site_databases do |t|
      t.string :name, null: false
      t.bigint :site_setup_id, null: false
      t.string :ownership_token, null: false
      t.boolean :bootstrapped, default: false, null: false
      t.timestamps
    end
    add_index :site_databases, :name, unique: true
    add_index :site_databases, :site_setup_id, unique: true
    create_table :site_database_sync_requests do |t|
      t.bigint :deployment_id, null: false
      t.string :status, null: false, default: 'pending'
      t.string :error_message
      t.timestamps
    end
  end
  def down
    raise ActiveRecord::IrreversibleMigration, 'Provisioning records contain ownership tokens and retry state. Preserve them and use a reviewed forward migration.'
  end
end
