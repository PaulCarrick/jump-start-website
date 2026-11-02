require 'digest'

class SiteRoutes
  class Unavailable < StandardError; end
  Route = Data.define(:setup_id, :database, :path, :key, :ready)
  CACHE = ActiveSupport::Cache::MemoryStore.new(size: 2.megabytes)
  LOOPBACK_HOSTS = %w[localhost 127.0.0.1 ::1].freeze
  TTL = 5.seconds

  def self.clear!
    CACHE.clear
  end

  def self.resolve(host, path)
    return Route.new(nil, nil, '', nil, true) unless SiteSetup.columns_hash.key?('routing_host')
    host = host.to_s.downcase.delete_suffix('.')
    return nil if host.blank? || host.bytesize > 253
    routes = CACHE.fetch([ CatalogRecord.connection_db_config.database, host ], expires_in: TTL) { load_host(host) }
    routes.find { |route| route.path.empty? || path == route.path || path.start_with?("#{route.path}/") }
  end

  def self.load_host(host)
    connection = CatalogRecord.connection
    host_condition = "s.routing_host = #{connection.quote(host)}"
    if (Rails.env.development? || Rails.env.test?) && LOOPBACK_HOSTS.include?(host)
      # Treat the default site's production origin as the local request origin.
      # Keep paths and database identities intact; never rewrite stored setups.
      host_condition = "(#{host_condition} OR s.routing_host = (SELECT routing_host FROM site_setups WHERE default_setup AND temporal_state = 'live' AND validity @> #{connection.quote(Time.current)}::timestamptz LIMIT 1))"
    end
    sql = <<~SQL
      SELECT s.id, s.database, s.routing_path, s.default_setup, s.enabled, s.temporal_deleted, d.bootstrapped, d.ownership_token
      FROM site_setups s LEFT JOIN site_databases d ON d.site_setup_id = s.id AND d.name = s.database
      WHERE #{host_condition} AND s.temporal_state = 'live'
        AND s.validity @> #{connection.quote(Time.current)}::timestamptz
    SQL
    rows = connection.select_all(sql).to_a
    aliases = ENV.fetch('DEFAULT_SITE_HOSTS', '').split(',').map(&:strip)
    aliases += LOOPBACK_HOSTS if Rails.env.development? || Rails.env.test?
    aliases += %w[www.example.com example.com] if Rails.env.test?
    if aliases.include?(host) && rows.none? { |row| row['default_setup'] }
      default = SiteSetup.live_versions.where(default_setup: true).first
      rows << { 'id' => default&.id, 'default_setup' => true, 'routing_path' => '', 'enabled' => default&.enabled, 'temporal_deleted' => default&.temporal_deleted }
    end
    if rows.reject { |row| row['temporal_deleted'] || row['enabled'] == false }.group_by { |row| row['routing_path'] }.any? { |_, matches| matches.map { |row| row['id'] }.uniq.size > 1 }
      raise Unavailable, 'Multiple sites map to the same local path.'
    end
    rows.map do |row|
      catalog = row['default_setup']
      token = row['ownership_token']
      key = catalog ? nil : Digest::SHA256.hexdigest("#{CatalogRecord.connection_db_config.database}:#{row['id']}:#{token}")[0, 24]
      ready = if row['enabled'] == false || row['temporal_deleted']
                :disabled
              else
                catalog || row['bootstrapped'] == true
              end
      Route.new(row['id'], catalog ? nil : row['database'], row['routing_path'], key, ready)
    end.sort_by { |route| [ -route.path.length, route.ready == :disabled ? 1 : 0 ] }.freeze
  end
end
