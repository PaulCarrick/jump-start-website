# Devise's failure app normally reads a process-wide relative_url_root. A site
# mount is request-local, including invalid-password recalls and login redirects.
module SiteDeviseMount
  protected

  def relative_url_root
    request.script_name.presence || super
  end
end
