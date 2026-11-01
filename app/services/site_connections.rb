require 'digest'

class SiteConnections
  MUTEX = Mutex.new
  POOLS = {}

  def self.shard_for(database)
    return :default if database.blank? || database == CatalogRecord.connection_db_config.database
    MUTEX.synchronize do
      if POOLS.key?(database)
        POOLS[database][:last_used] = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        return POOLS[database][:shard]
      end
      registration = SiteDatabase.find_by(name: database, bootstrapped: true)
      raise SiteRoutes::Unavailable, 'Site database is not ready.' unless registration
      limit = ENV.fetch('SITE_DATABASE_POOL_LIMIT', 64).to_i
      if POOLS.size >= limit
        name, entry = POOLS.find { |_, item| Process.clock_gettime(Process::CLOCK_MONOTONIC) - item[:last_used] > 30 && item[:pool].connections.none?(&:in_use?) }
        raise SiteRoutes::Unavailable, 'Site connection capacity reached.' unless entry
        ApplicationRecord.connection_handler.remove_connection_pool(ApplicationRecord.connection_specification_name, role: :writing, shard: entry[:shard])
        POOLS.delete(name)
      end
      shard = "site_#{Digest::SHA256.hexdigest(database)[0, 20]}".to_sym
      config = CatalogRecord.connection_db_config.configuration_hash.merge(database: database,
        pool: ENV.fetch('SITE_DATABASE_POOL_SIZE', 5).to_i, database_tasks: false)
      db_config = ActiveRecord::DatabaseConfigurations::HashConfig.new(Rails.env, shard.to_s, config)
      pool = ApplicationRecord.connection_handler.establish_connection(db_config, owner_name: ApplicationRecord, role: :writing, shard: shard)
      begin
        required = CatalogRecord.connection.select_values('SELECT version FROM schema_migrations').sort
        pool.with_connection do |connection|
          token = connection.select_value('SELECT token FROM jump_start_site_database_ownership LIMIT 1')
          raise SiteRoutes::Unavailable, 'Site database ownership does not match.' unless token == registration.ownership_token
          actual = connection.select_values('SELECT version FROM schema_migrations').sort
          raise SiteRoutes::Unavailable, 'Site database migrations are pending.' unless actual == required
        end
      rescue StandardError
        ApplicationRecord.connection_handler.remove_connection_pool(ApplicationRecord.connection_specification_name, role: :writing, shard: shard)
        raise SiteRoutes::Unavailable, 'Site database schema is not ready.'
      end
      POOLS[database] = { shard: shard, pool: pool, last_used: Process.clock_gettime(Process::CLOCK_MONOTONIC) }
      shard
    end
  end

  def self.with(route)
    raise SiteRoutes::Unavailable, 'Site database is not ready.' unless route.ready == true
    shard = shard_for(route.database)
    SiteContext.set(database: route.database, setup_id: route.setup_id, mount_path: route.path, key: route.key) do
      ApplicationRecord.connected_to(role: :writing, shard: shard) do
        ApplicationRecord.prohibit_shard_swapping { yield }
      end
    end
  end

  def self.clear!
    MUTEX.synchronize do
      POOLS.each_value do |entry|
        ApplicationRecord.connection_handler.remove_connection_pool(ApplicationRecord.connection_specification_name, role: :writing, shard: entry[:shard])
      end
      POOLS.clear
    end
  end
end
