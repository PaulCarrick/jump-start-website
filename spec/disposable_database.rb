# Loaded before Rails so even plain `rspec` cannot select a shared database.
require "rbconfig"

unless ENV["JUMPSTART_TEST_DATABASE"] == ENV["DB_DATABASE"] &&
       ENV.fetch("DB_DATABASE", "").match?(/\Ajump_start_(?:backend|rspec)_\d+_\d+\z/)
  ENV["RAILS_ENV"] = "test"
  ENV["DB_HOST"] = "localhost"
  ENV["DB_DATABASE"] = "jump_start_rspec_#{Process.pid}_#{Time.now.to_i}"
  ENV["JUMPSTART_TEST_DATABASE"] = ENV.fetch("DB_DATABASE")
  ENV.delete("DATABASE_URL")
  ENV.delete("DOCKERIZED")
  ENV["PATH"] = "#{File.dirname(RbConfig.ruby)}#{File::PATH_SEPARATOR}#{ENV.fetch('PATH')}"
  database = "#{ENV.fetch('DB_DATABASE')}_test"
  database_env = { "RAILS_ENV" => "test", "DB_HOST" => "localhost",
                   "DB_DATABASE" => ENV.fetch("DB_DATABASE"),
                   "DATABASE_URL" => nil, "DOCKERIZED" => nil }
  warn "RSpec isolated database: #{database} (no development data copied)"

  at_exit do
    ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord::Base)
    abort "Could not remove #{database}" unless system(database_env, "bundle", "exec", "rails", "db:drop")
  end
  abort "Could not prepare isolated RSpec database" unless system("bundle", "exec", "rails", "db:create", "db:schema:load")
end
