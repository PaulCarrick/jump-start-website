require 'uri'

class IndexSiteSetupRouting < ActiveRecord::Migration[8.1]
  def up
    execute "SET LOCAL lock_timeout = '10s'"
    drop_versioning_hook :site_setups, :site_setups_history, primary_key: [:id, :version]
    %i[site_setups site_setups_history].each do |table|
      add_column table, :routing_host, :string
      add_column table, :routing_path, :string
      connection.select_all("SELECT ctid::text AS locator, id, site_url FROM #{quote_table_name(table)}").each do |row|
        begin
          value = row['site_url'].to_s.strip
          # Older setups accepted bare domains. Derive host/path metadata without
          # rewriting their original URL or fabricating temporal history.
          if value.match?(%r{\A(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z]{2,}(?::\d+)?(?:/|$)})
            value = "https://#{value}"
          end
          uri = URI.parse(value)
          host = uri.hostname&.downcase&.delete_suffix('.')
          path = uri.path.to_s.delete_suffix('/')
          unless uri.is_a?(URI::HTTP) && host.present? && uri.userinfo.nil? && uri.query.nil? && uri.fragment.nil? && path.match?(%r{\A(?:/[A-Za-z0-9._~-]+)*\z}) && path.split('/').none? { |part| %w[. ..].include?(part) }
            raise 'Invalid URL'
          end
        rescue StandardError
          raise "Repair the Site URL for #{table} record #{row['id']} before enabling database routing."
        end
        execute "UPDATE #{quote_table_name(table)} SET routing_host = #{connection.quote(host)}, routing_path = #{connection.quote(path)} WHERE ctid = #{connection.quote(row['locator'])}::tid"
      end
      change_column_null table, :routing_host, false
      change_column_null table, :routing_path, false
    end
    add_index :site_setups, :site_url
    add_index :site_setups, [:routing_host, :routing_path], name: 'index_site_setups_routing_lookup'
    add_exclusion_constraint :site_setups, 'routing_host WITH =, routing_path WITH =, validity WITH &&', using: :gist,
      where: 'enabled AND NOT temporal_deleted', name: 'site_setups_unique_live_route'
    create_versioning_hook :site_setups, :site_setups_history, primary_key: [:id, :version]
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Database routing requires a reviewed rollback of code and all managed schemas.'
  end
end
