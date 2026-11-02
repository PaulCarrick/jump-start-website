require 'pg'
require 'securerandom'

# The current app database owns the catalog. Other connections are isolated PG
# clients; provisioning never changes Rails' active connection or request routing.
class SiteDatabaseProvisioner
  class Error < StandardError; end
  NAME = /\A[a-zA-Z0-9][a-zA-Z0-9_-]{0,62}\z/
  RESERVED = %w[postgres template0 template1].freeze
  MARKER = 'jump_start_site_database_ownership'.freeze

  def self.valid_name?(name)
    name.is_a?(String) && NAME.match?(name) && !RESERVED.include?(name.downcase)
  end

  def self.preflight!
    new.preflight!
  end

  def preflight!
    setups = working_setups
    default = setups.find(&:default_setup)
    raise Error, 'A default site setup is required.' unless default
    targets = setups.reject(&:default_setup)
    return true if targets.empty?
    targets.each do |setup|
      raise Error, 'Use a database name containing only letters, numbers, hyphens, or underscores (up to 63 characters).' unless self.class.valid_name?(setup.database)
      raise Error, 'A site database cannot replace the catalog database.' if setup.database == source_database
      existing = SiteDatabase.find_by(site_setup_id: setup.id)
      if existing && existing.name != setup.database
        raise Error, 'Changing a provisioned database name requires a separate database migration.'
      end
    end
    if targets.any? { |setup| !SiteDatabase.find_by(name: setup.database)&.bootstrapped? }
      unless File.readable?(Rails.root.join('db/structure.sql'))
        raise Error, 'The SQL schema file is missing from this release.'
      end
      targets.each do |setup|
        if SiteSetupNaming.slug(setup).blank?
          raise Error, 'Site Name must contain letters or numbers to create the administrator email.'
        end
        unless URI::MailTo::EMAIL_REGEXP.match?("guest@#{setup.site_domain}")
          raise Error, 'Use a valid Site Domain so the guest email address can be created.'
        end
      end
      password!
      unless User.password_length.cover?(password!.length) && password!.bytesize <= 72
        raise Error, 'USER_PASSWORD does not meet the user password length requirements.'
      end
    end
    with_database(source_database) do |catalog|
      targets.each do |setup|
        next if SiteDatabase.exists?(name: setup.database)
        unless catalog.exec("SELECT rolcreatedb OR rolsuper AS allowed FROM pg_roles WHERE rolname = current_user").first['allowed'] == 't'
          raise Error, 'The database role needs CREATEDB permission before a new site can be deployed.'
        end
        if catalog.exec_params('SELECT 1 FROM pg_database WHERE datname = $1', [ setup.database ]).ntuples.positive?
          raise Error, "Database #{setup.database} already exists and is not managed by this application. It will not be overwritten."
        end
      end
    end
    true
  rescue PG::Error
    raise Error, 'Could not check site databases. Verify database connectivity and permissions before deploying.'
  end

  def enroll!
    working_setups.reject(&:default_setup).each do |setup|
      SiteDatabase.find_or_create_by!(site_setup_id: setup.id) do |registration|
        registration.name = setup.database
        registration.ownership_token = SecureRandom.uuid
      end
    end
  end

  def synchronize!
    # Source snapshots include temporal versions and native history, not website
    # content. Syncing the complete catalog also propagates deletions/disabled rows.
    setups = SiteSetup.live_versions.where(temporal_deleted: false).to_a
    default = setups.find(&:default_setup)
    raise Error, 'A default site setup is required.' unless default
    snapshot = source_snapshot
    setups.reject(&:default_setup).each do |setup|
      registration = SiteDatabase.find_by!(site_setup_id: setup.id)
      raise Error, 'Changing a provisioned database name requires a separate database migration.' if registration.name != setup.database
      provision!(registration, setup)
    end
    # Keep previously provisioned databases in sync even if a setup is disabled
    # or deleted. This step never drops databases or website data.
    SiteDatabase.order(:id).each do |registration|
      with_database(registration.name) do |target|
        verify_ownership!(target, registration)
        target.transaction { copy_catalog!(target, snapshot) }
      end
    end
  end

  private

  def working_setups
    PublishingContext.set(live: false) { SiteSetup.all.to_a }
  end

  def source
    SiteSetup.connection
  end

  def source_database
    SiteSetup.connection_db_config.database
  end

  def password!
    ENV['USER_PASSWORD'].presence || raise(Error, 'USER_PASSWORD must be set before deploying a new site setup.')
  end

  def with_database(name)
    config = source.raw_connection.conninfo_hash.reject { |_, value| value.nil? || value == '' }.merge('dbname' => name, 'connect_timeout' => '10')
    connection = PG.connect(config)
    connection.exec("SET TIME ZONE 'UTC'")
    yield connection
  ensure
    connection&.close
  end

  def provision!(registration, setup)
    # PostgreSQL CREATE DATABASE cannot participate in the deployment transaction.
    # A database comment records ownership before schema loading, so interrupted
    # initialization is retryable without adopting unrelated databases.
    with_database(source_database) do |catalog|
      row = catalog.exec_params("SELECT shobj_description(oid, 'pg_database') AS marker FROM pg_database WHERE datname = $1", [ registration.name ]).first
      marker = "jump-start:#{registration.ownership_token}"
      if row
        raise Error, "Database #{registration.name} is not owned by this provisioning request." unless row['marker'] == marker
      else
        if registration.bootstrapped?
          raise Error, "Managed database #{registration.name} is missing. Restore it from backup before retrying."
        end
        catalog.exec("CREATE DATABASE #{catalog.quote_ident(registration.name)}")
        catalog.exec("COMMENT ON DATABASE #{catalog.quote_ident(registration.name)} IS #{catalog.escape_literal(marker)}")
      end
    end
    with_database(registration.name) do |target|
      if target.exec("SELECT to_regclass('public.#{MARKER}') AS table_name").first['table_name'].nil?
        # Load schema and ownership marker atomically: failed initialization leaves
        # an empty, owned database that can be retried without deleting anything.
        sql = File.read(Rails.root.join('db/structure.sql')).lines.reject { |line| line.match?(/^\\(?:un)?restrict\b/) }.join
        raise Error, 'The SQL schema contains unsupported psql commands.' if sql.match?(/^\\/)
        target.transaction do
          target.exec(sql)
          target.exec('SET search_path TO public')
          target.exec_params("INSERT INTO ar_internal_metadata (key, value, created_at, updated_at) VALUES ('environment', $1, NOW(), NOW()) ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW()", [ Rails.env ])
          target.exec("CREATE TABLE #{MARKER} (token text NOT NULL)")
          target.exec_params("INSERT INTO #{MARKER} (token) VALUES ($1)", [ registration.ownership_token ])
        end
      end
      target.exec('SET search_path TO public')
      verify_ownership!(target, registration)
      return if registration.bootstrapped?
      target.transaction do
        bootstrap_admin_links!(target)
        bootstrap_users!(target, setup)
        copy_catalog!(target, source_snapshot)
        # The marker and seed rows commit together. It also makes retries safe if
        # source status persistence fails after this target transaction commits.
        target.exec("ALTER TABLE #{MARKER} ADD COLUMN IF NOT EXISTS bootstrapped boolean NOT NULL DEFAULT false")
        target.exec("UPDATE #{MARKER} SET bootstrapped = true")
      end unless target_bootstrapped?(target)
    end
    registration.update!(bootstrapped: true)
  end

  def verify_ownership!(target, registration)
    token = target.exec("SELECT token FROM #{MARKER} LIMIT 1").first&.fetch('token', nil)
    raise Error, "Database #{registration.name} has an invalid ownership marker." unless token == registration.ownership_token
  end

  def target_bootstrapped?(target)
    target.exec("SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = '#{MARKER}' AND column_name = 'bootstrapped'").ntuples.positive? &&
      target.exec("SELECT bootstrapped FROM #{MARKER}").first['bootstrapped'] == 't'
  end

  def bootstrap_admin_links!(target)
    [ MenuItem, FooterItem ].each do |model|
      rows = model.live_versions.where(temporal_deleted: false).where("link LIKE '/admin%'").map { |item| item.attributes }
      ids = rows.map { |row| row['id'] }
      rows.each do |row|
        # Preserve hierarchy among copied admin links, never point into uncopied
        # public menus or pages from the source website.
        row['parent_id'] = nil unless ids.include?(row['parent_id'])
        row['page_id'] = nil
        insert_identity!(target, model.table_name, row['id'])
      end
      rows.each { |row| insert!(target, model.table_name, row) }
      reset_sequence!(target, model.table_name)
    end
  end

  def bootstrap_users!(target, setup)
    guest_name = setup.guest_user_name.presence || 'guest'
    accounts = [
      { email: "guest@#{setup.site_domain}", name: guest_name, access: 'regular', password: SecureRandom.hex(32) },
      { email: SiteSetupNaming.admin_email(setup), name: SiteSetupNaming.owner(setup), access: 'admin', password: password! }
    ]
    accounts.each_with_index do |attributes, index|
      user = User.new(attributes.merge(password_confirmation: attributes[:password], enabled: true, approved: true))
      # Validations against the source users table would incorrectly reject an
      # email already used on another website. Only the target owns these users.
      unless URI::MailTo::EMAIL_REGEXP.match?(attributes[:email]) && attributes[:name].present?
        raise Error, 'Check the site domain and guest user name before provisioning.'
      end
      row = user.attributes.merge('id' => index + 1, 'version' => 1, 'temporal_state' => 'live',
        'validity' => "[#{Time.current.utc.iso8601(6)},infinity)", 'created_at' => Time.current, 'updated_at' => Time.current)
      insert_identity!(target, 'users', row['id'])
      insert!(target, 'users', row)
    end
    reset_sequence!(target, 'users')
  end

  def source_snapshot
    %w[site_setups site_setups_history].to_h { |table| [ table, source.select_all("SELECT * FROM #{source.quote_table_name(table)}").to_a ] }
  end

  def copy_catalog!(target, snapshot)
    # The catalog is authoritative. Preserve exact temporal periods while avoiding
    # synthetic history generated by replaying replication writes.
    target.exec('ALTER TABLE site_setups DISABLE TRIGGER USER')
    target.exec('DELETE FROM site_setups')
    target.exec('DELETE FROM site_setups_history')
    snapshot['site_setups'].each { |row| insert_identity!(target, 'site_setups', row['id']) }
    snapshot.each { |table, rows| rows.each { |row| insert!(target, table, row) } }
    target.exec('ALTER TABLE site_setups ENABLE TRIGGER USER')
    reset_sequence!(target, 'site_setups')
  end

  def insert_identity!(target, table, id)
    target.exec_params("INSERT INTO #{target.quote_ident("#{table}_identities")} (id) VALUES ($1) ON CONFLICT DO NOTHING", [ id ])
  end

  def insert!(target, table, attributes)
    columns = attributes.keys
    values = attributes.values.map do |value|
      case value
      when Hash, Array then value.to_json
      when Time, DateTime then value.iso8601(6)
      when Range then value.begin ? "[#{value.begin.utc.iso8601(6)},#{value.end ? value.end.utc.iso8601(6) : 'infinity'})" : 'empty'
      else value
      end
    end
    target.exec_params("INSERT INTO #{target.quote_ident(table)} (#{columns.map { |key| target.quote_ident(key) }.join(',')}) VALUES (#{columns.each_index.map { |index| "$#{index + 1}" }.join(',')})", values)
  end

  def reset_sequence!(target, table)
    target.exec_params("SELECT setval(pg_get_serial_sequence($1, 'id'), GREATEST(COALESCE((SELECT max(id) FROM #{target.quote_ident(table)}), 0), 1), EXISTS(SELECT 1 FROM #{target.quote_ident(table)}))", [ table ])
  end
end
