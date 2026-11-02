require 'fileutils'
require 'uri'

namespace :site_databases do
  desc 'Migrate managed site schemas without switching the running application connection'
  task migrate: :environment do
    source = CatalogRecord.connection_db_config.configuration_hash
    failures = []
    SiteDatabase.order(:id).each do |site|
      provisioner = SiteDatabaseProvisioner.new
      begin
        initialized = false
        provisioner.send(:with_database, site.name) do |connection|
          marker = connection.exec("SELECT to_regclass('public.#{SiteDatabaseProvisioner::MARKER}') AS marker").first['marker']
          if marker
            provisioner.send(:verify_ownership!, connection, site)
            initialized = true
          end
        end
        unless initialized
          puts "#{site.name}: not initialized; finish provisioning with Retry Database Sync."
          next
        end
        environment = {
          'RAILS_ENV' => Rails.env, 'DB_DATABASE' => site.name,
          'DB_HOST' => source[:host].to_s, 'DB_PORT' => source.fetch(:port, 5432).to_s,
          'DB_USERNAME' => source[:username].to_s, 'DB_PASSWORD' => source[:password].to_s,
          'DATABASE_URL' => nil, 'DOCKERIZED' => nil, 'SITE_DATABASE_MIGRATION' => 'true'
        }
        host = source[:host].presence || 'localhost'
        query = host.start_with?('/') ? { host: host } : {}
        environment['DATABASE_URL'] = URI::Generic.build(
          scheme: 'postgresql', host: host.start_with?('/') ? 'localhost' : host,
          port: source.fetch(:port, 5432).to_i,
          userinfo: [ source[:username], source[:password] ].map { |part| URI.encode_www_form_component(part.to_s) }.join(':'),
          path: "/#{site.name}", query: query.empty? ? nil : URI.encode_www_form(query)
        ).to_s
        %w[sslmode sslcert sslkey sslrootcert].each do |option|
          environment["PG#{option.upcase}"] = source[option.to_sym].to_s if source[option.to_sym]
        end
        configurations = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env)
        task = configurations.size > 1 && configurations.any? { |config| config.name == 'primary' } ? 'db:migrate:primary' : 'db:migrate'
        FileUtils.mkdir_p(Rails.root.join('log'))
        path = Rails.root.join('log', "site-database-migration-#{site.id}.log")
        success = File.open(path, File::WRONLY | File::CREAT | File::TRUNC, 0o600) do |log|
          system(environment, RbConfig.ruby, Rails.root.join('bin/rails').to_s, task, out: log, err: [ :child, :out ])
        end
        raise 'Migration command failed' unless success
        puts "#{site.name}: migrated."
      rescue StandardError => error
        failures << site.name
        warn "#{site.name}: migration failed (#{error.class.name}); check its migration log."
      end
    end
    SiteRoutes.clear!
    SiteConnections.clear!
    abort "Site database migrations failed: #{failures.join(', ')}" if failures.any?
  end
end
