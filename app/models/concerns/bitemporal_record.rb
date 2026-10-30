# The application keeps scalar IDs; database PKs and query constraints isolate
# each version. Native application-time rows hold drafts with EMPTY validity.
module BitemporalRecord
  extend ActiveSupport::Concern
  MODELS = %w[BlogPost Cell Contact FooterItem ImageFile MenuItem Page PostComment Section SiteSetup User].freeze
  META = %w[id version validity temporal_state base_version base_updated_at deployment_id temporal_deleted created_at updated_at].freeze

  included do
    include ActiveRecord::Temporal
    application_versioning dimensions: :validity
    application_versioned
    system_versioning
    system_versioned
    self.primary_key = :id
    if table_exists? && columns_hash.key?('version')
      query_constraints :id, :version
    else
      query_constraints :id
    end
    default_scope { working_or_live }
    before_create :prepare_temporal_origin
  end

  class_methods do
    def working_or_live
      return where(nil) if name.start_with?('History::')
      return all unless columns_hash.key?("validity")
      table = quoted_table_name
      time = connection.quote(PublishingContext.valid_at || Time.current)
      active = "#{table}.temporal_state = 'live' AND #{table}.validity @> #{time}::timestamptz"
      if PublishingContext.live != false && !PublishingContext.preview
        where("#{active} AND NOT #{table}.temporal_deleted")
      else
        where("NOT #{table}.temporal_deleted AND (#{table}.temporal_state = 'draft' OR (#{active} AND NOT EXISTS (SELECT 1 FROM #{table} AS pending WHERE pending.id = #{table}.id AND pending.temporal_state = 'draft')))")
      end
    end

    def live_versions(at: Time.current)
      unscoped.where(temporal_state: 'live').where('validity @> ?::timestamptz', at)
    end

    def pending_versions
      unscoped.where(temporal_state: 'draft')
    end

    def bitemporal_at(valid_at:, known_at:)
      history.as_of(validity: valid_at, system_period: known_at)
    end
  end

  def draft?
    has_attribute?(:temporal_state) && temporal_state == 'draft'
  end

  # Discardable deletions are versions too. Retain live rows and attachments.
  def destroy
    return super unless PublishingContext.editing && !PublishingContext.deploying
    self.temporal_deleted = true
    save!(validate: false)
    @draft_deleted = true
    self
  end

  def destroyed?
    @draft_deleted || super
  end

  def destroy!
    return super unless PublishingContext.editing && !PublishingContext.deploying
    destroy
  end

  private

  def prepare_temporal_origin
    return unless has_attribute?(:validity)
    connection = self.class.connection
    connection.execute('SELECT pg_advisory_xact_lock(87342, 1)') if PublishingContext.editing
    if id.nil?
      self.version = 1
      self.base_version = nil
      self.base_updated_at = nil
      self.deployment_id = nil
      sequence = connection.select_value("SELECT pg_get_serial_sequence(#{connection.quote(self.class.table_name)}, 'id')")
      self.id = connection.select_value("SELECT nextval(#{connection.quote(sequence)})")
    end
    anchor = connection.quote_table_name("#{self.class.table_name}_identities")
    connection.execute("INSERT INTO #{anchor} (id) VALUES (#{connection.quote(id)}) ON CONFLICT DO NOTHING")
    self.version ||= 1
    if PublishingContext.editing && !PublishingContext.deploying
      self.temporal_state = 'draft'
      self.validity = nil
      clear_attribute_change(:validity) # Omit it on INSERT: PostgreSQL EMPTY default.
    else
      self.temporal_state ||= 'live'
      self.validity ||= (Time.current...nil)
    end
  end

  def attributes_for_create(attribute_names)
    # Rails casts PostgreSQL EMPTY to nil. Omit the field on draft INSERTs so
    # PostgreSQL supplies EMPTY rather than receiving an explicit NULL.
    attribute_names = attribute_names - [ 'validity' ] if draft?
    super(attribute_names)
  end

  def _update_row(*args, **options)
    # Active Storage defers touch timestamps and clears their dirty state before
    # writing them. They are audit maintenance, not a separate content edit.
    return super if args[1] == 'touch'
    return super unless PublishingContext.editing && !PublishingContext.deploying
    connection = self.class.connection
    connection.execute('SELECT pg_advisory_xact_lock(87342, 1)')
    expected = PublishingContext.expected_versions&.fetch([ self.class.name, id ], nil)
    if expected
      expected_time = expected[1].present? ? Time.zone.parse(expected[1].to_s) : nil
      if expected[0] != version_in_database || (expected_time && expected_time.iso8601(3) != attribute_in_database('updated_at').iso8601(3))
        raise ActiveRecord::StaleObjectError.new(self, 'save an outdated browser form; reopen the draft')
      end
    end
    stored_time = self.class.unscoped.where(id: id, version: version_in_database).pick(:updated_at)
    if stored_time&.iso8601(6) != attribute_in_database('updated_at')&.iso8601(6)
      raise ActiveRecord::StaleObjectError.new(self, 'save an outdated editor; reopen the draft')
    end
    return super if draft?
    table = self.class.quoted_table_name
    connection.execute("SELECT id FROM #{connection.quote_table_name("#{self.class.table_name}_identities")} WHERE id = #{connection.quote(id)} FOR UPDATE")
    if self.class.pending_versions.where(id: id).exists?
      raise ActiveRecord::StaleObjectError.new(self, 'save an outdated editor; reopen the current draft')
    end
    self.base_version = version_in_database
    self.base_updated_at = attribute_in_database('updated_at')
    self.version = self.class.unscoped.where(id: id).maximum(:version).to_i + 1
    self.temporal_state = 'draft'
    values = attributes.merge('validity' => Arel.sql("'empty'::tstzrange"))
    self.class.unscoped.insert_all!([ values ])
    self.validity = nil
    1
  end
end
