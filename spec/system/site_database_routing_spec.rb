require 'rails_helper'

RSpec.describe 'Browser navigation within a site database', type: :system do
  self.use_transactional_tests = false
  before { driven_by(:selenium_chrome_headless) }

  after do
    Capybara.reset_sessions!
    SiteConnections.clear!
    if @database
      raise 'Unsafe browser test database' unless @database.match?(/\Ajump_start_browser_\d+_[a-f0-9]+\z/)
      SiteDatabaseProvisioner.new.send(:with_database, CatalogRecord.connection_db_config.database) do |connection|
        connection.exec("DROP DATABASE IF EXISTS #{connection.quote_ident(@database)} WITH (FORCE)")
      end
    end
    raise 'Unsafe source cleanup' unless CatalogRecord.connection_db_config.database.match?(/\Ajump_start_rspec_\d+_\d+_test\z/)
    tables = CatalogRecord.connection.tables - %w[schema_migrations ar_internal_metadata]
    CatalogRecord.connection.execute("TRUNCATE #{tables.map { |table| CatalogRecord.connection.quote_table_name(table) }.join(', ')} RESTART IDENTITY CASCADE")
  end

  it 'keeps browser login, editor API calls, upload dialogs, and deployment in the mount' do
    admin = create(:user, access: 'super')
    create(:page, name: 'home')
    catalog_cell = create(:cell, image: nil, link: nil, content: '<p>Catalog text stays unchanged</p>')
    visit root_path
    origin = URI.parse(page.current_url)
    @database = "jump_start_browser_#{Process.pid}_#{SecureRandom.hex(4)}"
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('USER_PASSWORD').and_return('Browser-routing-password-123')
    PublishingContext.editing = true
    site = create(:site_setup, default_setup: false, database: @database, configuration_name: 'browser-site',
                  site_name: 'browser-site', site_url: "#{origin.scheme}://#{origin.host}:#{origin.port}/browser-site")
    PublishingContext.editing = false
    Publishing.deploy!(actor: admin, summary: 'Browser routing test')
    route = SiteRoutes.resolve(origin.host, '/browser-site')
    cell = nil
    SiteConnections.with(route) do
      home = create(:page, name: 'home', title: 'Browser tenant home', section: 'browser-home')
      section = create(:section, page: home, content_type: home.section)
      cell = create(:cell, section: section, image: nil, link: nil, content: '<p>Original tenant text</p><a href="/home">Local home</a>')
    end
    visit '/browser-site/users/sign_in'
    fill_in 'Email Address', with: 'browser-site@example.com'
    fill_in 'Password', with: 'Browser-routing-password-123'
    click_button 'Log in'
    expect(page).to have_current_path(%r{\A/browser-site(?:/home|/admin)?/?\z}, ignore_query: true)
    visit "/browser-site/admin/cells/#{cell.id}/edit"
    expect(page).to have_content('Draft workspace')
    within('#cellPreview') { expect(page).to have_link('Local home', href: '/browser-site/home') }
    click_button 'New Image'
    expect(page).to have_css('iframe[src^="/browser-site/admin/image_files/new"]')
    within_frame(find('iframe[title="New Image form"]')) do
      expect(page).to have_field('image_file[name]')
    end
    within('dialog') { click_button 'Cancel' }
    enter_column_text 'Published within this tenant only'
    click_button 'Save Column'
    expect(page).to have_current_path('/browser-site/admin/cells', ignore_query: true)
    visit '/browser-site/admin/publishing'
    click_button 'Deploy Changes'
    expect(page).to have_content('Changes deployed successfully')
    visit '/browser-site/home'
    expect(page).to have_content('Published within this tenant only')
    expect(Cell.find(catalog_cell.id).content).to include('Catalog text stays unchanged')
  end
end
