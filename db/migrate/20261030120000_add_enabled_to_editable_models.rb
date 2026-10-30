class AddEnabledToEditableModels < ActiveRecord::Migration[8.0]
  TABLES = %i[blog_posts cells contacts footer_items image_files menu_items pages post_comments sections site_setups users].freeze

  def up
    TABLES.each do |table|
      add_column table, :enabled, :boolean, default: true, null: false
      # Preserve existing timestamps; safely backfill only columns missing on a deployment.
      %i[created_at updated_at].each do |timestamp|
        next if column_exists?(table, timestamp)
        add_column table, timestamp, :datetime
        execute "UPDATE #{quote_table_name(table)} SET #{quote_column_name(timestamp)} = CURRENT_TIMESTAMP WHERE #{quote_column_name(timestamp)} IS NULL"
        change_column_null table, timestamp, false
      end
    end
  end

  def down
    TABLES.each { |table| remove_column table, :enabled }
    # Existing/backfilled audit timestamps are deliberately preserved.
  end
end
