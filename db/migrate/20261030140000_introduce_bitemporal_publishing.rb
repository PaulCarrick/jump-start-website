# Run with web/background writers stopped; all DDL and the baseline are atomic.
class IntroduceBitemporalPublishing < ActiveRecord::Migration[8.1]
  TABLES = %w[blog_posts cells contacts footer_items image_files menu_items pages post_comments sections site_setups users].freeze

  def up
    execute "SET LOCAL lock_timeout = '10s'"
    execute "SET LOCAL TIME ZONE 'UTC'"
    raise 'PostgreSQL 13 or newer is required' if connection.database_version < 130000
    enable_extension :btree_gist unless extension_enabled?(:btree_gist)

    # Repoint existing foreign keys at stable identity anchors before allowing
    # multiple native application-time versions with the same logical ID.
    foreign_keys = TABLES.flat_map do |table|
      connection.foreign_keys(table).select { |fk| TABLES.include?(fk.to_table) }.map { |fk| [ table, fk ] }
    end
    TABLES.each do |table|
      create_table "#{table}_identities", id: :bigint
      execute "INSERT INTO #{quote_table_name("#{table}_identities")} (id) SELECT id FROM #{quote_table_name(table)}"
    end
    foreign_keys.each { |table, fk| remove_foreign_key table, name: fk.name }

    TABLES.each do |table|
      add_column table, :version, :bigint, null: false, default: 1
      add_column table, :validity, :tstzrange, null: false, default: 'empty'
      add_column table, :temporal_state, :string, null: false, default: 'live'
      add_column table, :base_version, :bigint
      add_column table, :base_updated_at, :datetime
      add_column table, :deployment_id, :bigint
      add_column table, :temporal_deleted, :boolean, null: false, default: false
      add_column table, :attachment_blob_id, :bigint if table == 'image_files'
      execute "UPDATE #{quote_table_name(table)} SET validity = tstzrange(created_at, NULL, '[)')"

      connection.indexes(table).select(&:unique).each do |index|
        # Existing names stay unique within any overlapping live period. Drafts
        # have empty validity and are validated again as a group on deployment.
        unless index.columns.is_a?(Array) && index.where.nil?
          raise "Review nonstandard unique index #{index.name} before migrating"
        end
        remove_index table, name: index.name
        columns = index.columns.map { |column| "#{quote_column_name(column)} WITH =" }
        add_exclusion_constraint table, (columns + [ 'validity WITH &&' ]).join(', '), using: :gist, name: "#{index.name}_period"
      end
      execute "ALTER TABLE #{quote_table_name(table)} DROP CONSTRAINT #{quote_column_name("#{table}_pkey")}, ADD PRIMARY KEY (id, version)"
      add_exclusion_constraint table, 'id WITH =, validity WITH &&', using: :gist, name: "#{table}_validity_overlap"
      add_index table, :id, unique: true, where: "temporal_state = 'draft'", name: "#{table}_one_draft"
      add_check_constraint table, "temporal_state IN ('live', 'draft')", name: "#{table}_temporal_state"
      add_check_constraint table, "(temporal_state = 'draft' AND isempty(validity)) OR (temporal_state = 'live' AND NOT isempty(validity))", name: "#{table}_temporal_validity"
      add_foreign_key table, "#{table}_identities", column: :id

      history = "#{table}_history"
      execute "CREATE TABLE #{quote_table_name(history)} (LIKE #{quote_table_name(table)} INCLUDING DEFAULTS)"
      add_column history, :system_period, :tstzrange, null: false
      execute "ALTER TABLE #{quote_table_name(history)} ADD PRIMARY KEY (id, version, system_period)"
      add_exclusion_constraint history, 'id WITH =, version WITH =, system_period WITH &&', using: :gist, name: "#{history}_system_overlap"
      create_versioning_hook table, history, primary_key: [ :id, :version ]
      columns = connection.columns(table).map { |c| quote_column_name(c.name) }.join(', ')
      execute "INSERT INTO #{quote_table_name(history)} (#{columns}, system_period) SELECT #{columns}, tstzrange(CURRENT_TIMESTAMP, 'infinity', '[)') FROM #{quote_table_name(table)}"
    end
    foreign_keys.each do |table, fk|
      add_foreign_key table, "#{fk.to_table}_identities", column: fk.column, name: fk.name, on_delete: fk.on_delete, on_update: fk.on_update
    end
    create_table :deployments do |t|
      t.bigint :actor_id
      t.datetime :effective_at, null: false
      t.text :summary
      t.timestamps
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Temporal history must not be discarded. Restore the pre-migration backup only before accepting new writes; otherwise use a forward repair.'
  end
end
