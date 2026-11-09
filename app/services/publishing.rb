class Publishing
  class Conflict < StandardError; end

  def self.models
    names = SiteContext.tenant? ? BitemporalRecord::MODELS - [ 'SiteSetup' ] : BitemporalRecord::MODELS
    names.map(&:constantize)
  end

  def self.pending
    models.flat_map { |model| model.pending_versions.to_a }.sort_by { |record| [ record.class.name, record.id ] }
  end

  # only: publish just these drafts, given as [class name, id] pairs (the
  # review page publishes whole groups); nil publishes everything pending.
  # contents: what was published, in plain words, for the history.
  def self.deploy!(actor:, summary:, only: nil, contents: nil)
    raise SecurityError, 'Administrator access is required' unless actor&.admin?
    only = only&.map { |model_name, id| [ model_name.to_s, id.to_i ] }&.to_set
    deployment = ApplicationRecord.transaction do
      # Serialize deployment and discard, and lock the actual draft rows. The
      # model callbacks also lock identity anchors when creating a draft.
      ApplicationRecord.connection.execute('SELECT pg_advisory_xact_lock(87342, 1)')
      drafts = models.flat_map { |model| model.pending_versions.order(:id).lock.to_a }
      drafts = drafts.select { |draft| only.include?([ draft.class.name, draft.id ]) } if only
      raise Conflict, 'There are no pending changes.' if drafts.empty?
      site_setup_changes = drafts.any? { |draft| draft.is_a?(SiteSetup) }
      if site_setup_changes
        begin
          provisioner = SiteDatabaseProvisioner.new
          provisioner.preflight!
          provisioner.enroll!
        rescue SiteDatabaseProvisioner::Error => error
          raise Conflict, error.message
        end
      end
      now = Time.current
      attributes = { actor_id: actor.id, effective_at: now, summary: summary }
      attributes[:contents] = contents.to_s.truncate(2000) if contents.present? && Deployment.column_names.include?('contents')
      deployment = Deployment.create!(attributes)
      old_context = PublishingContext.deploying
      old_live = PublishingContext.live
      PublishingContext.deploying = true
      PublishingContext.live = false
      drafts.each do |draft|
        model = draft.class
        live = model.live_versions(at: now).where(id: draft.id).lock.first
        if draft.base_version.present? && (live.nil? || live.version != draft.base_version || live.updated_at != draft.base_updated_at)
          raise Conflict, "#{model.model_name.human} #{draft.id} changed since this draft began."
        end
        if live
          # Closing the old period must not validate obsolete content against
          # the pending workspace. All new versions are validated below.
          live.restore_attributes
          live.set_time_dimension_end(now)
          live.save!(validate: false)
        end
      end
      drafts.each do |draft|
        draft.temporal_state = 'live'
        draft.set_time_dimension_start(now)
        draft.deployment_id = deployment.id
        draft.save!(validate: !draft.temporal_deleted?)
      end
      # Check all associations after all members are promoted, before COMMIT.
      # Foreign keys ensure identities exist; this additionally checks that
      # newly published dependants have a current, non-deleted parent.
      drafts.each do |draft|
        next if draft.temporal_deleted?
        draft.class.reflect_on_all_associations(:belongs_to).each do |reflection|
          next if reflection.polymorphic? || !BitemporalRecord::MODELS.include?(reflection.class_name)
          foreign_id = draft[reflection.foreign_key]
          next if foreign_id.nil? && reflection.options[:optional]
          if foreign_id && !reflection.klass.live_versions(at: now).where(id: foreign_id, temporal_deleted: false).exists?
            raise Conflict, "#{draft.class.model_name.human} #{draft.id} has an unpublished #{reflection.name}."
          end
        end
      end
      SiteDatabaseSyncRequest.create!(deployment_id: deployment.id) if site_setup_changes
      deployment
    ensure
      PublishingContext.deploying = old_context
      PublishingContext.live = old_live unless old_live.nil?
    end
    # PostgreSQL database creation is outside the content transaction. Persist the
    # synchronization request first so failures/crashes are explicitly retryable.
    if SiteContext.catalog?
      SiteDatabaseSyncRequest.find_by(deployment_id: deployment.id)&.run!
      SiteRoutes.clear!
    end
    deployment
  end

  SENSITIVE = %w[encrypted_password password reset_password_token reset_password_sent_at remember_created_at smtp_password captcha_secret_key].freeze

  def self.review_attributes(record)
    record.attributes.except(*(BitemporalRecord::META + SENSITIVE + %w[system_period checksum]))
  end

  def self.restore!(model:, id:, version:, recorded_at: nil)
    previous = PublishingContext.editing
    raise ActiveRecord::RecordNotFound unless models.include?(model)
    versions = model.history.where(id: id, version: version)
    versions = versions.where('system_period @> ?::timestamptz', recorded_at) if recorded_at
    historical = versions.order(system_period: :desc).first!
    record = model.pending_versions.find_by(id: id) || model.live_versions.find_by(id: id) || raise(ActiveRecord::RecordNotFound)
    PublishingContext.editing = true
    record.assign_attributes(review_attributes(historical))
    record.temporal_deleted = false
    record.save!
    record
  ensure
    PublishingContext.editing = previous
  end

  # only: discard just these drafts ([class name, id] pairs); nil discards all.
  def self.discard!(only: nil)
    only = only&.map { |model_name, id| [ model_name.to_s, id.to_i ] }&.to_set
    ApplicationRecord.transaction do
      ApplicationRecord.connection.execute('SELECT pg_advisory_xact_lock(87342, 1)')
      models.each do |model|
        model.pending_versions.lock.each do |draft|
          next if only && !only.include?([ model.name, draft.id ])

          model.unscoped.where(id: draft.id, version: draft.version).delete_all
        end
      end
    end
  end
end
