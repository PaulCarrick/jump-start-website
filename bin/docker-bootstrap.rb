# Create starter content once; never reset existing accounts on restart.
require Rails.root.join('db/seeds/admin_defaults')
if User.unscoped.exists?
  puts 'Existing installation found; keeping accounts and content.'
else
  password = ENV.fetch('ADMIN_PASSWORD')
  email = ENV.fetch('ADMIN_EMAIL')
  raise 'ADMIN_PASSWORD must be at least 16 characters' if password.length < 16
  data = JSON.parse(File.read(Rails.root.join('db/seeds/admin_defaults.json')))
  setup = data.fetch('site_setup').first
  setup['database'] = ENV.fetch('DB_DATABASE', 'jump_start')
  setup['site_url'] = ENV.fetch('SITE_URL', 'http://localhost:3000')
  setup['site_host'] = setup['site_domain'] = URI.parse(setup['site_url']).host
  PublishingContext.set(editing: false, deploying: false, live: false, preview: false) do
    CatalogRecord.transaction do
      AdminDefaultsSeed.seed_setup!(setup)
      AdminDefaultsSeed.seed_navigation!(MenuItem, data.fetch('menu_items'))
      AdminDefaultsSeed.seed_navigation!(FooterItem, data.fetch('footer_items'))
      AdminDefaultsSeed.seed_home!(data)
      User.create!(email: email, name: 'Administrator', access: 'super', enabled: true,
        password: password, password_confirmation: password)
    end
  end
  SiteRoutes.clear!
  puts 'Starter site and administrator created.'
end
