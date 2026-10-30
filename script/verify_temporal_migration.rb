# Run: RAILS_ENV=test bundle exec rails runner script/verify_temporal_migration.rb
# Creates and drops its own database. Never runs the migration on the caller DB.
require 'factory_bot_rails'
require Rails.root.join('db/migrate/20261030140000_introduce_bitemporal_publishing')
require Rails.root.join('db/migrate/20261030180000_normalize_temporal_history_infinity')

original_config = ActiveRecord::Base.connection_db_config.configuration_hash
name = "jump_start_temporal_rehearsal_#{Process.pid}_#{Time.now.to_i}_test"
raise 'Unsafe rehearsal database name' unless name.match?(/\Ajump_start_temporal_rehearsal_\d+_\d+_test\z/)
ActiveRecord::Base.connection.execute("CREATE DATABASE #{ActiveRecord::Base.connection.quote_column_name(name)}")
begin
  ActiveRecord::Base.establish_connection(original_config.merge(database: name))
  ActiveRecord::Migration.verbose = false
  load Rails.root.join('spec/fixtures/pre_temporal_schema.rb')
  BitemporalRecord::MODELS.each { |model| model.constantize.reset_column_information; model.constantize.query_constraints :id }
  BitemporalRecord::MODELS.each do |model|
    if model == 'PostComment'
      FactoryBot.create(:post_comment, id: nil, blog_post: FactoryBot.create(:blog_post))
    else
      FactoryBot.create(model.underscore.to_sym)
    end
  end
  connection = ActiveRecord::Base.connection
  before = IntroduceBitemporalPublishing::TABLES.to_h do |table|
    [ table, connection.select_all("SELECT * FROM #{connection.quote_table_name(table)} ORDER BY id").to_a ]
  end
  # Execute the real Rails command in a fresh process, just as in deployment.
  migration_env = {
    'RAILS_ENV' => 'test', 'DB_DATABASE' => name.delete_suffix('_test'),
    'DB_HOST' => original_config[:host].to_s, 'DB_PORT' => original_config[:port].to_s,
    'DB_USERNAME' => original_config[:username].to_s, 'DB_PASSWORD' => original_config[:password].to_s,
    'DATABASE_URL' => nil, 'DOCKERIZED' => nil
  }
  output = Rails.root.join('tmp/temporal-migration-rehearsal.log').to_s
  unless system(migration_env, RbConfig.ruby, Rails.root.join('bin/rails').to_s, 'db:migrate', out: output, err: [ :child, :out ])
    raise "Migration rehearsal failed; see #{output}"
  end
  connection.schema_cache.clear!
  BitemporalRecord::MODELS.each { |model| model.constantize.reset_column_information; model.constantize.query_constraints :id, :version }
  before.each do |table, rows|
    after = connection.select_all("SELECT * FROM #{connection.quote_table_name(table)} ORDER BY id").to_a
    raise "Row count changed for #{table}" unless rows.size == after.size
    rows.zip(after).each do |old_row, new_row|
      raise "Existing values changed in #{table}" unless new_row.slice(*old_row.keys) == old_row
      raise "Baseline not live in #{table}" unless new_row['version'] == 1 && new_row['temporal_state'] == 'live'
    end
    history_count = connection.select_value("SELECT count(*) FROM #{connection.quote_table_name("#{table}_history")}")
    raise "History baseline missing in #{table}" unless history_count == rows.size
  end
  # Also rehearse repair of databases that ran the initial release, whose
  # baselines used an unbounded range instead of an explicit infinity timestamp.
  before.each_key do |table|
    history = connection.quote_table_name("#{table}_history")
    raise "Fresh baseline has an unbounded period" if connection.select_value("SELECT EXISTS(SELECT 1 FROM #{history} WHERE upper_inf(system_period))")
    connection.execute("UPDATE #{history} SET system_period = tstzrange(lower(system_period), NULL, '[)')")
  end
  ApplicationRecord.transaction { NormalizeTemporalHistoryInfinity.new.migrate(:up) }
  # Exercise the first post-migration write against every backfilled baseline.
  # Native hooks must close that period before recording a new observation.
  before.each_key do |table|
    connection.execute("UPDATE #{connection.quote_table_name(table)} SET enabled = NOT enabled")
    count = connection.select_value("SELECT count(*) FROM #{connection.quote_table_name("#{table}_history")}")
    raise "Initial history period did not close in #{table}" unless count == before[table].size * 2
  end
  puts "PASS: populated migration preserves all existing values, IDs, timestamps and row counts across eleven models; native history baselines created and first post-migration writes verified."
ensure
  ActiveRecord::Base.connection_pool.disconnect!
  ActiveRecord::Base.establish_connection(original_config)
  ActiveRecord::Base.connection.execute("DROP DATABASE #{ActiveRecord::Base.connection.quote_column_name(name)} WITH (FORCE)")
end
