require 'rails_helper'

RSpec.describe SiteDatabaseProvisioner do
  let(:admin) { create(:user, access: 'super') }
  let!(:default) { create(:site_setup) }

  before do
    @database_names = []
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('USER_PASSWORD').and_return('Provision-test-password-123')
  end

  after do
    @database_names.each do |name|
      raise 'Unsafe test database cleanup' unless name.match?(/\Ajump_start_provision_\d+_[a-f0-9]+\z/)
      described_class.new.send(:with_database, SiteSetup.connection_db_config.database) do |connection|
        connection.exec("DROP DATABASE IF EXISTS #{connection.quote_ident(name)} WITH (FORCE)")
      end
    end
  end

  def new_site
    name = "jump_start_provision_#{Process.pid}_#{SecureRandom.hex(4)}"
    @database_names << name
    previous = PublishingContext.editing
    PublishingContext.editing = true
    create(:site_setup, default_setup: false, configuration_name: name, database: name,
           site_domain: 'new-site.example', site_url: "https://jumpstartserver.com/#{name}", guest_user_name: 'Guest User', site_name: 'jumpstart-website', owner_name: 'Jumpstart Website')
  ensure
    PublishingContext.editing = previous
  end

  def target(name, &block)
    described_class.new.send(:with_database, name, &block)
  end

  it 'creates a fresh database on deployment, copies only admin navigation, and seeds users' do
    create(:user, email: 'admin@example.com', name: 'Source administrator')
    root = create(:menu_item, link: '/admin', label: 'Admin Root')
    child = create(:menu_item, parent: root, link: '/admin/pages', label: 'Manage Pages')
    create(:menu_item, link: '/public', label: 'Public menu')
    create(:footer_item, link: '/admin/users', label: 'Manage Users')
    create(:footer_item, link: '/contact', label: 'Contact')
    site = new_site
    expect(SiteDatabase.count).to eq(0)
    deployment = Publishing.deploy!(actor: admin, summary: 'Provision website')
    expect(SiteDatabaseSyncRequest.find_by!(deployment_id: deployment.id).status).to eq('completed')
    expect(SiteSetup.connection_db_config.database).not_to eq(site.database)
    target(site.database) do |connection|
      expect(connection.exec('SELECT label FROM menu_items ORDER BY id').map { |row| row['label'] }).to eq([ 'Admin Root', 'Manage Pages' ])
      expect(connection.exec_params('SELECT parent_id FROM menu_items WHERE id = $1', [ child.id ]).first['parent_id'].to_i).to eq(root.id)
      expect(connection.exec('SELECT label FROM footer_items').first['label']).to eq('Manage Users')
      users = connection.exec('SELECT email, name, access, encrypted_password FROM users').to_a
      guest = users.find { |row| row['email'] == 'guest@new-site.example' }
      expect(guest.slice('name', 'access')).to eq('name' => 'Guest User', 'access' => 'regular')
      account = users.find { |row| row['email'] == 'jumpstart-website@example.com' }
      expect(account['access']).to eq('admin')
      expect(account['name']).to eq('Jumpstart Website')
      expect(BCrypt::Password.new(account['encrypted_password'])).to eq('Provision-test-password-123')
      expect(connection.exec('SELECT count(*) FROM pages').first['count']).to eq('0')
      expect(connection.exec('SELECT count(*) FROM site_setups').first['count']).to eq('2')
    end
  end

  it 'rejects missing USER_PASSWORD before publishing or creating a database' do
    site = new_site
    allow(ENV).to receive(:[]).with('USER_PASSWORD').and_return(nil)
    expect { Publishing.deploy!(actor: admin, summary: '') }.to raise_error(Publishing::Conflict, /USER_PASSWORD/)
    expect(SiteDatabase.count).to eq(0)
    expect(SiteSetup.live_versions.where(id: site.id)).not_to exist
    expect(SiteSetup.pending_versions.where(id: site.id)).to exist
  end

  it 'synchronizes every site setup to every managed database and retries without resetting users' do
    first = new_site
    second = new_site
    Publishing.deploy!(actor: admin, summary: 'Two sites')
    target(first.database) { |connection| connection.exec("UPDATE users SET name = 'Customized administrator' WHERE email = 'jumpstart-website@example.com'") }
    PublishingContext.editing = true
    SiteSetup.find(default.id).update!(site_name: 'Changed catalog')
    PublishingContext.editing = false
    Publishing.deploy!(actor: admin, summary: 'Change default')
    [ first, second ].each do |site|
      target(site.database) do |connection|
        expect(connection.exec_params('SELECT site_name FROM site_setups WHERE id = $1 AND validity @> NOW()', [ default.id ]).first['site_name']).to eq('Changed catalog')
        expect(connection.exec('SELECT count(*) FROM site_setups_history').first['count'].to_i).to be >= 3
      end
    end
    SiteDatabaseSyncRequest.create!(deployment_id: Deployment.last.id).run!
    target(first.database) do |connection|
      expect(connection.exec("SELECT name FROM users WHERE email = 'jumpstart-website@example.com'").first['name']).to eq('Customized administrator')
      expect(connection.exec('SELECT count(*) FROM users').first['count']).to eq('2')
    end
  end

  it 'refuses to adopt an unrelated existing database' do
    site = new_site
    target(SiteSetup.connection_db_config.database) { |connection| connection.exec("CREATE DATABASE #{connection.quote_ident(site.database)}") }
    expect { Publishing.deploy!(actor: admin, summary: '') }.to raise_error(Publishing::Conflict, /already exists/)
    expect(SiteDatabase.count).to eq(0)
  end
  it 'records a provisioning failure and safely resumes initialization on retry' do
    site = new_site
    attempts = 0
    allow_any_instance_of(described_class).to receive(:bootstrap_users!).and_wrap_original do |method, *args|
      attempts += 1
      raise described_class::Error, 'Simulated interruption' if attempts == 1
      method.call(*args)
    end
    deployment = Publishing.deploy!(actor: admin, summary: 'Interrupted setup')
    request = SiteDatabaseSyncRequest.find_by!(deployment_id: deployment.id)
    expect(request.status).to eq('failed')
    expect(SiteSetup.live_versions.where(id: site.id)).to exist
    expect(request.run!).to be(true)
    expect(request.reload.status).to eq('completed')
    target(site.database) do |connection|
      expect(connection.exec('SELECT count(*) FROM users').first['count']).to eq('2')
    end
  end

  it 'does not provision or synchronize while a site setup is only a saved draft' do
    new_site
    expect(SiteDatabase.count).to eq(0)
    expect(SiteDatabaseSyncRequest.count).to eq(0)
  end
end
