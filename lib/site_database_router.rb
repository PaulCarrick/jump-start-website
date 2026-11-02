# Runs after Rails' executor but before cookies, sessions, Warden, and controllers.
class SiteDatabaseRouter
  def initialize(app)
    @app = app
  end

  def call(env)
    original_script = env['SCRIPT_NAME'].to_s
    original_path = env['PATH_INFO'].to_s
    # Do not trust client-supplied X-Forwarded-Host for database selection.
    authority = env['HTTP_HOST'].presence || env['SERVER_NAME']
    uri = URI.parse("http://#{authority}")
    return response(400, 'Invalid request host.') if uri.userinfo || uri.path.present? || uri.query || uri.fragment
    route = SiteRoutes.resolve(uri.hostname, original_path)
    return response(404, 'No site is configured for this address.') unless route && route.ready != :disabled
    decoded = Rack::Utils.unescape_path(original_path)
    return response(400, 'Invalid request path.') if decoded.include?('\\') || decoded.split('/').any? { |part| %w[. ..].include?(part) }
    if decoded != original_path
      decoded_route = SiteRoutes.resolve(uri.hostname, decoded)
      return response(400, 'Ambiguous site path.') unless decoded_route && decoded_route.setup_id == route.setup_id && decoded_route.path == route.path
    end
    env['jumpstart.site_key'] = route.key
    if route.path.present?
      env['SCRIPT_NAME'] = original_script + route.path
      env['PATH_INFO'] = original_path.delete_prefix(route.path).presence || '/'
    end
    SiteConnections.with(route) { @app.call(env) }
  rescue URI::InvalidURIError
    response(400, 'Invalid request host.')
  rescue SiteRoutes::Unavailable, ActiveRecord::ConnectionNotEstablished, ActiveRecord::NoDatabaseError, PG::ConnectionBad => error
    Rails.logger.error("Site routing unavailable: #{error.class.name}")
    response(503, 'This site is temporarily unavailable. Please contact the administrator.')
  ensure
    env['SCRIPT_NAME'] = original_script
    env['PATH_INFO'] = original_path
  end

  private

  def response(status, message)
    [ status, { 'content-type' => 'text/plain; charset=utf-8', 'cache-control' => 'no-store' }, [ message ] ]
  end
end
