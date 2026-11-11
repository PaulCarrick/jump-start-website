require 'rails_helper'
require Rails.root.join('db/seeds/admin_defaults')

RSpec.describe AdminDefaultsSeed do
  around do |example|
    user_password = ENV['USER_PASSWORD']
    ENV['USER_PASSWORD'] = 'seed-password-12345'
    old = ENV['SEED_SMTP_PASSWORD']
    ENV['SEED_SMTP_PASSWORD'] = 'seed-test-password'
    example.run
  ensure
    ENV['SEED_SMTP_PASSWORD'] = old
    ENV['USER_PASSWORD'] = user_password
  end

  it 'creates the captured setup and admin navigation as live records, and is repeatable' do
    described_class.load!
    expect(SiteSetup.find_by(default_setup: true)).to have_attributes(
      configuration_name: 'default', site_name: 'Jump Start Website',
      site_url: 'http://localhost:3000', database: 'jump-start',
      routing_host: 'localhost', routing_path: ''
    )
    expect(MenuItem.count).to eq(16)
    expect(FooterItem.count).to eq(5)
    expect(MenuItem.where('link LIKE ?', '/admin%').count).to eq(11)
    expect(MenuItem.where(menu_type: 'Help').order(:menu_order).pluck(:label, :link)).to eq([
      [ 'Help', '/admin/help' ], [ 'Video Tutorial', '/tutorial/jump-start-website-tutorial.mp4' ], [ 'New Site Tutorial', '/admin/tutorial' ]
    ])
    expect(MenuItem.root_main_menu_items.pluck(:label)).to eq([ 'Home', 'Contact', 'Search', 'Admin Dashboard', 'Login' ])
    expect(MenuItem.where(options: 'image-file').pluck(:icon)).to contain_exactly(
      '/images/search.svg', '/images/gear.svg', '/images/keys.svg'
    )
    footer = FooterItem.root_footer_items.sole
    expect(footer.label).to eq('OTHER')
    expect(footer.sub_items.order(:footer_order).pluck(:label)).to eq([ 'Contact', 'Search Website', 'Admin Dashboard', 'Login' ])
    home = Page.find_by!(name: 'home')
    expect(home.title).to eq('Home Page')
    section = home.ordered_sections.sole
    expect(section.page_id).to eq(home.id)
    expect(section.description).to include('Hello World!', 'Welcome to the Jump Start web Server.')
    expect(section.cells).to be_empty
    expect(section.temporal_state).to eq('live')
    expect(MenuItem.pending_versions).to be_empty
    expect(MenuItem.live_versions.count).to eq(16)
    expect { described_class.load! }.not_to change { [ SiteSetup.unscoped.count, MenuItem.unscoped.count, FooterItem.unscoped.count, Page.unscoped.count, Section.unscoped.count, Cell.unscoped.count ] }
  end

  it 'seeds the OTHER footer group with all four links' do
    described_class.load!
    footer = FooterItem.root_footer_items.sole
    expect(footer.label).to eq('OTHER')
    expect(footer.sub_items.order(:footer_order).pluck(:label, :link)).to eq([
      [ 'Contact', '/contacts/new' ],
      [ 'Search Website', '/search/new' ],
      [ 'Admin Dashboard', '/admin' ],
      [ 'Login', '/users/sign_in' ]
    ])
    expect { described_class.load! }.not_to change(FooterItem, :count)
  end

  it 'preserves existing setup values and navigation edits, including disabled drafts' do
    setup = create(:site_setup)
    menu = MenuItem.create!(label: 'Custom users', link: '/admin/users', menu_type: 'Admin', menu_order: 99)
    # Simulate an existing imported draft; admin navigation is read-only in the UI.
    PublishingContext.set(editing: true) do
      menu.assign_attributes(label: 'Pending users', enabled: false)
      menu.save!(validate: false)
    end
    ENV.delete('SEED_SMTP_PASSWORD') # Not needed when the setup already exists.
    described_class.load!
    expect(setup.reload.site_name).to eq('Jump Start Server')
    expect(MenuItem.find(menu.id)).to have_attributes(label: 'Pending users', enabled: false, menu_order: 99)
    expect(MenuItem.unscoped.where(link: '/admin/users').count).to eq(2) # Live + existing draft.
  end

  it 'preserves an existing home page and section on subsequent runs' do
    described_class.load!
    Page.find_by!(name: 'home').update!(title: 'My home')
    Section.first.update!(description: '<p>My content</p>')
    described_class.load!
    expect(Page.find_by!(name: 'home').title).to eq('My home')
    expect(Section.first.description).to eq('<p>My content</p>')
  end

  it 'seeds the two users with source profiles and an environment-provided password' do
    described_class.load!
    expect(User.count).to eq(2)
    guest = User.find_by!(email: 'guest@example.com')
    admin = User.find_by!(email: 'jump_start@example.com')
    expect(guest).to have_attributes(name: 'Guest User', access: 'regular', enabled: true)
    expect(admin).to have_attributes(name: 'jump_start', access: 'admin', enabled: true)
    expect(admin.valid_password?(ENV.fetch('USER_PASSWORD'))).to be(true)
    expect(guest.valid_password?(ENV.fetch('USER_PASSWORD'))).to be(true)
    expect(User.pending_versions).to be_empty
    admin.update!(name: 'Custom admin', password: 'changed-password-123')
    ENV.delete('USER_PASSWORD')
    expect { described_class.load! }.not_to change(User, :count)
    expect(admin.reload.name).to eq('Custom admin')
    expect(admin.valid_password?('changed-password-123')).to be(true)
  end

  it 'fails before creating records when new users need a password' do
    ENV.delete('USER_PASSWORD')
    expect { described_class.load! }.to raise_error(/USER_PASSWORD/)
    expect(SiteSetup.count).to eq(0)
    expect(User.count).to eq(0)
  end

  it 'remaps copied parents without depending on their source IDs' do
    rows = [
      { 'id' => 901, 'label' => 'Child', 'link' => '/admin/child', 'parent_id' => 900 },
      { 'id' => 900, 'label' => 'Parent', 'link' => '/admin/parent', 'parent_id' => nil }
    ]
    described_class.seed_navigation!(FooterItem, rows)
    expect(FooterItem.find_by(link: '/admin/child').parent_id).to eq(FooterItem.find_by(link: '/admin/parent').id)
  end
end

RSpec.describe 'Seeded basic website', type: :request do
  it 'renders the home content, header icons, and grouped footer from a fresh seed' do
    original_password = ENV['USER_PASSWORD']
    ENV['USER_PASSWORD'] = 'seed-password-12345'
    AdminDefaultsSeed.load!
    host! 'localhost'
    get '/home'
    expect(response).to have_http_status(:ok)
    document = Nokogiri::HTML(response.body)
    expect(document.at_css('header').text).to include('Home', 'Contact')
    # Visitors who are not signed in do not see links into the admin area.
    header_icons = document.css('header img').map { |image| image['src'] }
    expect(header_icons).to include('/images/search.svg', '/images/keys.svg')
    expect(header_icons).not_to include('/images/gear.svg')
    expect(document.at_css('footer').text).to include('OTHER', 'Contact', 'Search Website', 'Login')
    expect(document.at_css('footer').text).not_to include('Admin Dashboard')
    expect(response.body).to include('Hello World!', 'Welcome to the Jump Start web Server.')
  ensure
    ENV['USER_PASSWORD'] = original_password
  end
end
