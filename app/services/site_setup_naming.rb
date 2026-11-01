class SiteSetupNaming
  def self.slug(setup)
    setup.site_name.to_s.parameterize
  end

  def self.owner(setup)
    setup.owner_name.presence || slug(setup).split('-').map(&:capitalize).join(' ')
  end

  def self.admin_email(setup)
    "#{slug(setup)}@example.com"
  end
end
