# The gem closes periods by comparing upper(system_period) to the explicit
# PostgreSQL timestamp 'infinity'. An unbounded upper range returns NULL instead.
class NormalizeTemporalHistoryInfinity < ActiveRecord::Migration[8.1]
  TABLES = %w[blog_posts cells contacts footer_items image_files menu_items pages post_comments sections site_setups users].freeze

  def up
    execute "SET LOCAL lock_timeout = '10s'"
    TABLES.each do |table|
      execute <<~SQL
        UPDATE #{quote_table_name("#{table}_history")}
        SET system_period = tstzrange(lower(system_period), 'infinity', '[)')
        WHERE upper_inf(system_period)
      SQL
    end
  end

  def down
    # Explicit infinity is the gem's required representation; retain it.
  end
end
