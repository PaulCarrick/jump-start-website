require 'rails_helper'

class RoutingProbeJob < ApplicationJob
  class_attribute :results, default: []
  def perform(user, fail_after_read: false)
    self.class.results += [ [ user.email, Page.first&.title, ApplicationRecord.connection_db_config.database ] ]
    raise 'simulated job error' if fail_after_read
  end
end

RSpec.describe 'URL-selected site databases', type: :request do
  self.use_transactional_tests = false
  let!(:catalog_setup) { create(:site_setup) }
  let!(:catalog_admin) { create(:user, access: 'super') }

  before do
    @databases = []
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('USER_PASSWORD').and_return('Routing-test-password-123')
    create(:page, name: 'home', title: 'Catalog Home', section: 'catalog-home')
    @a = provision_site('tenant-a')
    @b = provision_site('tenant-b')
    [ @a, @b ].each do |site|
      within_site(site) do
        page = create(:page, name: 'home', title: "#{site.site_name} Home", section: site.site_name)
        section = create(:section, page: page, content_type: page.section)
        create(:cell, section: section, image: nil, link: nil, content: "<p>Only #{site.site_name}</p><a href=\"/home\">Local home</a>")
      end
    end
    SiteRoutes.clear!
  end

  after do
    SiteConnections.clear!
    @databases.each do |name|
      raise 'Unsafe routing test database' unless name.match?(/\Ajump_start_routing_\d+_[a-f0-9]+\z/)
      SiteDatabaseProvisioner.new.send(:with_database, CatalogRecord.connection_db_config.database) do |connection|
        connection.exec("DROP DATABASE IF EXISTS #{connection.quote_ident(name)} WITH (FORCE)")
      end
    end
    database = CatalogRecord.connection_db_config.database
    raise 'Unsafe source cleanup' unless database.match?(/\Ajump_start_rspec_\d+_\d+_test\z/)
    tables = CatalogRecord.connection.tables - %w[schema_migrations ar_internal_metadata]
    CatalogRecord.connection.execute("TRUNCATE #{tables.map { |table| CatalogRecord.connection.quote_table_name(table) }.join(', ')} RESTART IDENTITY CASCADE")
  end

  def provision_site(path)
    name = "jump_start_routing_#{Process.pid}_#{SecureRandom.hex(4)}"
    @databases << name
    PublishingContext.editing = true
    site = create(:site_setup, default_setup: false, configuration_name: path, database: name,
      site_name: path, site_url: "http://www.example.com/#{path}", guest_user_name: 'guest')
    PublishingContext.editing = false
    deployment = Publishing.deploy!(actor: catalog_admin, summary: 'Routing test site')
    expect(SiteDatabaseSyncRequest.find_by!(deployment_id: deployment.id).status).to eq('completed')
    site
  end

  def within_site(site, &block)
    route = SiteRoutes.resolve('www.example.com', "/#{site.site_name}")
    SiteConnections.with(route, &block)
  end

  def login_to(site)
    post "/#{site.site_name}/users/sign_in", params: { user: { email: "#{site.site_name}@example.com", password: 'Routing-test-password-123' } }
    expect(response).to have_http_status(:redirect)
  end

  it 'serves stored production URLs on localhost without changing setup values' do
    PublishingContext.editing = true
    SiteSetup.find(@a.id).update!(site_url: "https://jumpstartserver.com/tenant-a")
    PublishingContext.editing = false
    Publishing.deploy!(actor: catalog_admin, summary: 'Production URL for local testing')
    host! 'localhost:3100'
    get '/tenant-a/home'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Only tenant-a', 'content="/tenant-a"')
    get '/home'
    expect(response.body).to include('Catalog Home')
    login_to(@a)
    expect(response.location).to start_with('http://localhost:3100/tenant-a')
    get '/tenant-a/admin/pages'
    expect(response).to have_http_status(:ok)
    expect(SiteSetup.find(@a.id).site_url).to eq('https://jumpstartserver.com/tenant-a')
  end

  it 'uses distinct data for GETs and API requests while retaining the default connection' do
    get '/tenant-a/home'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Only tenant-a', 'content="/tenant-a"')
    expect(response.body).not_to include('Only tenant-b')
    get '/tenant-b/api/v1/pages/home'
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)['title']).to eq('tenant-b Home')
    get '/home'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Catalog Home')
    expect(Page.find_by(name: 'home').title).to eq('Catalog Home')
    expect(SiteContext.database).to be_nil
  end

  it 'keeps password login, POST writes, redirects, and catalog administration isolated' do
    login_to(@a)
    expect(response.location).to include('/tenant-a')
    get '/tenant-a/admin/pages'
    expect(response).to have_http_status(:ok)
    get '/tenant-b/admin/pages'
    expect(response).to redirect_to('/tenant-b/users/sign_in')
    get '/admin/pages'
    expect(response).to redirect_to('/users/sign_in')
    post '/tenant-a/api/v1/pages', params: { page: { name: 'new-only-a', title: 'Pending A', section: 'new-only-a' } }
    expect(response).to have_http_status(:created)
    within_site(@a) { expect(Page.pending_versions.where(name: 'new-only-a')).to exist }
    within_site(@b) { expect(Page.unscoped.where(name: 'new-only-a')).not_to exist }
    expect(Page.unscoped.where(name: 'new-only-a')).not_to exist
    get '/tenant-a/admin/site_setups'
    expect(response).to have_http_status(:forbidden)
    get '/tenant-a/admin/publishing/history', params: { model: 'SiteSetup', record_id: @a.id }
    expect(response).to have_http_status(:not_found)
    before = SiteSetup.pending_versions.count
    post '/tenant-a/admin/publishing/restore', params: { model: 'SiteSetup', record_id: @a.id, version: 1 }
    expect(SiteSetup.pending_versions.count).to eq(before)
    expect(response).not_to have_http_status(:ok)
  end

  it 'rejects unknown hosts and never falls back to catalog data for unready sites' do
    get '/home', headers: { 'HTTP_HOST' => 'unknown.example' }
    expect(response).to have_http_status(:not_found)
    get '/tenant-a/home', headers: { 'HTTP_X_FORWARDED_HOST' => 'unknown.example' }
    expect(response).to have_http_status(:ok)
    SiteDatabase.find_by!(site_setup_id: @a.id).update!(bootstrapped: false)
    SiteRoutes.clear!
    get '/tenant-a/home'
    expect(response).to have_http_status(:service_unavailable)
    expect(response.body).not_to include('Catalog Home')
  end

  it 'uses segment boundaries and the longest prefix and caches route lookups' do
    nested = provision_site('tenant-a/nested')
    # Site names may contain slashes in this test, but its database and URL are safe.
    SiteRoutes.clear!
    count = 0
    callback = ->(_name, _start, _finish, _id, event) { count += 1 if event[:sql].include?('FROM site_setups s LEFT JOIN') }
    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') do
      expect(SiteRoutes.resolve('www.example.com', '/tenant-a/nested/home').setup_id).to eq(nested.id)
      20.times { expect(SiteRoutes.resolve('www.example.com', '/tenant-a/home').setup_id).to eq(@a.id) }
      expect(SiteRoutes.resolve('www.example.com', '/tenant-ab/home').key).to be_nil
    end
    expect(count).to eq(1)
  end

  it 'does not allow signed blob or disk URLs to cross sites with overlapping IDs' do
    urls = {}
    [ @a, @b ].each do |site|
      within_site(site) do
        image = create(:image_file)
        urls[site.site_name] = image.image_url
        expect(ActiveStorage::Blob.connection_pool).to equal(ImageFile.connection_pool)
      end
    end
    get urls['tenant-a']
    expect(response).to have_http_status(:redirect)
    disk_url = URI.parse(response.location).request_uri
    expect(disk_url).to start_with('/tenant-a/rails/active_storage/disk/')
    get disk_url
    expect(response).to have_http_status(:ok)
    get urls['tenant-a'].sub('/tenant-a/', '/tenant-b/')
    expect(response).to have_http_status(:not_found)
    get disk_url.sub('/tenant-a/', '/tenant-b/')
    expect(response).to have_http_status(:not_found)
  end

  it 'keeps background GlobalID deserialization and concurrent connections in the correct site' do
    payload = nil
    within_site(@a) { payload = RoutingProbeJob.new(User.find_by!(email: 'tenant-a@example.com')).serialize }
    RoutingProbeJob.results = []
    RoutingProbeJob.deserialize(payload).perform_now
    expect(RoutingProbeJob.results.last).to eq([ 'tenant-a@example.com', 'tenant-a Home', @a.database ])
    expect(SiteContext.database).to be_nil
    routes = [ @a, @b ].map { |site| SiteRoutes.resolve('www.example.com', "/#{site.site_name}") }
    barrier = Queue.new
    release = Queue.new
    threads = routes.map do |route|
      Thread.new do
        SiteConnections.with(route) do
          barrier << true
          release.pop
          [ Page.find_by!(name: 'home').title, ApplicationRecord.connection_db_config.database ]
        end
      ensure
        ApplicationRecord.connection_handler.clear_active_connections!
      end
    end
    2.times { barrier.pop }
    2.times { release << true }
    expect(threads.map(&:value)).to contain_exactly([ 'tenant-a Home', @a.database ], [ 'tenant-b Home', @b.database ])
    expect(Page.find_by!(name: 'home').title).to eq('Catalog Home')
  end
  it 'invalidates changed routes after deployment and reserves disabled mounts' do
    PublishingContext.editing = true
    SiteSetup.find(@a.id).update!(site_url: 'http://www.example.com/renamed-a')
    PublishingContext.editing = false
    Publishing.deploy!(actor: catalog_admin, summary: 'Move mount')
    get '/renamed-a/home'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Only tenant-a')
    PublishingContext.editing = true
    SiteSetup.find(@a.id).update!(enabled: false)
    PublishingContext.editing = false
    Publishing.deploy!(actor: catalog_admin, summary: 'Disable site')
    get '/renamed-a/home'
    expect(response).to have_http_status(:not_found)
    expect(response.body).not_to include('Catalog Home')
  end

  it 'refuses stale schemas and restores the default connection after exceptions' do
    within_site(@a) { ApplicationRecord.connection.execute("DELETE FROM schema_migrations WHERE version = '20261101160000'") }
    SiteConnections.clear!
    get '/tenant-a/home'
    expect(response).to have_http_status(:service_unavailable)
    expect(SiteContext.database).to be_nil
    expect(Page.find_by!(name: 'home').title).to eq('Catalog Home')
    route = SiteRoutes.resolve('www.example.com', '/tenant-b')
    expect { SiteConnections.with(route) { raise 'request failed' } }.to raise_error('request failed')
    expect(SiteContext.database).to be_nil
    expect(ApplicationRecord.current_shard).to eq(:default)
    within_site(@b) { ApplicationRecord.connection.execute("UPDATE jump_start_site_database_ownership SET token = 'wrong-owner'") }
    SiteConnections.clear!
    get '/tenant-b/home'
    expect(response).to have_http_status(:service_unavailable)
    expect(Page.find_by!(name: 'home').title).to eq('Catalog Home')
  end

  it 'keeps remember-me tokens and invalid-password recalls inside the mount' do
    post '/tenant-a/users/sign_in', params: { user: { email: 'tenant-a@example.com', password: 'wrong-password' } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('/tenant-a/users/sign_in')
    post '/tenant-a/users/sign_in', params: { user: { email: 'tenant-a@example.com', password: 'Routing-test-password-123', remember_me: '1' } }
    expect(response).to have_http_status(:redirect)
    remember_names = cookies.to_hash.keys.grep(/remember_user/)
    expect(remember_names.size).to eq(1)
    get '/tenant-b/admin/pages'
    expect(response).to redirect_to('/tenant-b/users/sign_in')
  end

  it 'migrates managed databases without changing the canonical schema artifact' do
    Rails.application.load_tasks unless Rake::Task.task_defined?('site_databases:migrate')
    before = Digest::SHA256.file(Rails.root.join('db/structure.sql')).hexdigest
    Rake::Task['site_databases:migrate'].reenable
    expect { Rake::Task['site_databases:migrate'].invoke }.not_to raise_error
    expect(Digest::SHA256.file(Rails.root.join('db/structure.sql')).hexdigest).to eq(before)
    get '/tenant-a/home'
    expect(response).to have_http_status(:ok)
  end
end
