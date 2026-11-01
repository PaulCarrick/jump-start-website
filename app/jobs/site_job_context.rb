# Preserve a tenant before ActiveJob deserializes GlobalIDs (blob IDs can overlap).
module SiteJobContext
  def serialize
    super.merge('jumpstart_site' => SiteContext.tenant? ? {
      'database' => SiteContext.database, 'setup_id' => SiteContext.setup_id
    } : nil)
  end

  def deserialize(data)
    @jumpstart_site = data['jumpstart_site']
    super
  end

  def perform_now
    site = @jumpstart_site || (SiteContext.tenant? ? { 'database' => SiteContext.database, 'setup_id' => SiteContext.setup_id } : nil)
    return super unless site
    registration = SiteDatabase.find_by(name: site['database'], site_setup_id: site['setup_id'], bootstrapped: true)
    raise SiteRoutes::Unavailable, 'Job site is not ready.' unless registration
    setup = SiteSetup.live_versions.where(id: registration.site_setup_id, temporal_deleted: false).first
    raise SiteRoutes::Unavailable, 'Job site no longer exists.' unless setup
    key = Digest::SHA256.hexdigest("#{CatalogRecord.connection_db_config.database}:#{setup.id}:#{registration.ownership_token}")[0, 24]
    route = SiteRoutes::Route.new(setup.id, registration.name, setup.routing_path, key, true)
    SiteConnections.with(route) { super }
  end
end
