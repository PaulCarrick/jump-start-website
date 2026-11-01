class SiteDatabaseSyncRequest < CatalogRecord
  def run!
    with_lock do
      return true if status == 'completed'
      # Serialize registry snapshots with deployments and other sync attempts.
      self.class.connection.execute('SELECT pg_advisory_xact_lock(87342, 1)')
      begin
        SiteDatabaseProvisioner.new.synchronize!
        update!(status: 'completed', error_message: nil)
        SiteRoutes.clear!
        true
      rescue SiteDatabaseProvisioner::Error, PG::Error => error
        # Never save SQL row contents, connection strings, or passwords in UI/logs.
        message = error.is_a?(SiteDatabaseProvisioner::Error) ? error.message : 'Database synchronization failed. Check database availability and permissions, then retry.'
        update!(status: 'failed', error_message: message.truncate(400))
        Rails.logger.error("Site database synchronization failed: #{error.class.name}")
        false
      end
    end
  end
end
