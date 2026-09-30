# Separate from rails_helper, whose system hooks replicate development data.
ENV['RAILS_ENV'] = 'test'
require_relative '../../config/environment'
require 'rspec/rails'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'fileutils'
require 'cgi'
require 'uri'
require 'rbconfig'
require_relative 'chrome_visibility'
require 'capybara/selenium/nodes/chrome_node'
Capybara::Selenium::ChromeNode.prepend(AdminE2EChromeVisibility)

module AdminE2E
  PASSWORD = 'Selenium-only-Password123!'
  EMAIL = 'admin@e2e.example'
  AREAS = { 'Site Setups'=>'site_setups', 'Users'=>'users', 'Menu Items'=>'menu_items',
    'Footer Items'=>'footer_items', 'Pages'=>'pages', 'Sections'=>'sections',
    'Cells'=>'cells', 'Image Files'=>'image_files', 'Blogs'=>'blog_posts' }.freeze

  def reset_empty_database!
    expected = "#{ENV.fetch('DB_DATABASE')}_test"
    actual = ActiveRecord::Base.connection_db_config.database
    abort "Refusing E2E cleanup of #{actual}" unless Rails.env.test? &&
      expected.match?(/\Ajump_start_ui_e2e_\d+_\d+_test\z/) && actual == expected
    connection = ActiveRecord::Base.connection
    tables = connection.tables - %w[schema_migrations ar_internal_metadata]
    connection.execute("TRUNCATE #{tables.map { |t| connection.quote_table_name(t) }.join(', ')} RESTART IDENTITY CASCADE")
    tables.each { |t| expect(connection.select_value("SELECT COUNT(*) FROM #{connection.quote_table_name(t)}").to_i).to eq(0) }
  end

  # No first-admin wizard exists. Only infrastructure is seeded; content is made in UI.
  def bootstrap!
    User.create!(email: EMAIL, name: 'UI Test Admin', password: PASSWORD, access: 'super')
    User.create!(email: 'guest@e2e.example', name: 'guest', password: PASSWORD, access: 'regular')
    SiteSetup.create!(configuration_name: 'bootstrap', default_setup: true,
      site_name: 'UI Test Site', owner_name: 'UI Test Admin', site_domain: 'localhost',
      site_host: 'localhost', site_url: 'http://localhost', guest_user_name: 'guest',
      header_background: '#0d6efd', header_text_color: '#ffffff',
      footer_background: '#0d6efd', footer_text_color: '#ffffff',
      container_background: '#f8f9fa', container_text_color: '#000000',
      page_background_image: 'none', copyright: 'Selenium test only')
    AREAS.each_with_index { |(label, resource), i| MenuItem.create!(menu_type: 'Admin', label: label, menu_order: i+1, link: "/admin/#{resource}") }
    MenuItem.create!(menu_type: 'Main', label: 'HOME', menu_order: 1, link: '/')
    MenuItem.create!(menu_type: 'Main', label: 'Admin Dashboard', menu_order: 2, link: '/admin', icon: '/images/gear.svg', options: 'image-file')
    MenuItem.create!(menu_type: 'Main', label: 'Login', menu_order: 3, link: '/users/sign_in')
    footer = FooterItem.create!(label: 'OTHER', footer_order: 1)
    FooterItem.create!(label: 'Admin Dashboard', footer_order: 2, parent: footer, link: '/admin')
  end

  def log_in
    visit '/users/sign_in'
    fill_field 'Email Address', with: EMAIL
    find('input[type=password]').set(PASSWORD)
    click_button 'Log in'
    expect(page).to have_current_path('/admin', ignore_query: true)
  end

  def area(resource)
    visit '/admin'; click_link AREAS.key(resource), exact: true
    expect(page).to have_current_path("/admin/#{resource}", ignore_query: true)
  end

  def clear_search
    path = URI(page.current_url).path
    click_link 'Clear Search'
    expect(page).to have_current_path("#{path}?clear_search=true")
  end

  def cancel
    page.has_button?('Cancel', wait: 0) ? click_button('Cancel', exact: true) : click_link('Cancel', exact: true)
  end

  def record_href(resource, label, action = 'View')
    raise 'Test labels cannot contain quotes' if label.include?("'")
    if %w[sections cells].include?(resource)
      container = find('.auto-size')
      expect(container).to have_content(label)
      return URI(container.find_link(action, exact: true)[:href]).request_uri
    end
    row = find('.scrollable-container').find(:xpath,
      ".//div[contains(concat(' ',normalize-space(@class),' '),' row ')][contains(.,'#{label}')][.//a[normalize-space(.)='#{action}']]", match: :first)
    URI(row.find_link(action, exact: true)[:href]).request_uri
  end

  def open_record(resource, label, action)
    # A save can still be redirecting when the previous list becomes visible.
    # Wait for the editor to leave before clicking a record on the new list.
    expect(page).to have_no_button(/\ASave /)
    href = record_href(resource, label, action)
    click_link action, href: href
    expect(page).to have_current_path(href, ignore_query: true)
    screenshot("#{resource}-#{action.downcase}")
  end

  def delete_record(resource, label)
    href = record_href(resource, label, 'Delete')
    dismiss_confirm { click_link 'Delete', href: href }
    expect(page).to have_link('Delete', href: href)
    accept_confirm { click_link 'Delete', href: href }
    expect(page).to have_no_link('Delete', href: href)
  end

  # Keyboard replacement lets controlled React inputs observe every change.
  def fill_field(locator, with:, **options)
    field = find_field(locator, **options)
    replace_field(field, with.to_s)
  end

  def replace_input(selector, value)
    replace_field(find(selector), value)
  end

  def replace_field(input, value)
    modifier = RbConfig::CONFIG['host_os'].include?('darwin') ? :command : :control
    input.click
    input.send_keys([modifier, 'a'], :backspace)
    input.send_keys(value) unless value.empty?
    input.send_keys(:tab)
    if input[:type] == 'number' && !value.empty?
      # React numeric controls can retain a leading zero when the empty value
      # is coerced to zero; compare the entered numeric value.
      expect(input.value.to_f).to eq(Float(value))
    else
      expect(input.value).to eq(value)
    end
  end

  def quill(text, index: 0)
    editor = all('.ql-editor[contenteditable=true]', minimum: index+1)[index]
    modifier = RbConfig::CONFIG['host_os'].include?('darwin') ? :command : :control
    editor.click; editor.send_keys([modifier, 'a'], text, :tab)
    expect(editor).to have_text(text)
  end

  def create_user(name = 'E2E Member')
    area('users'); click_link 'New User'
    fill_field 'Email*', with: "#{name.downcase.tr(' ', '-')}@e2e.example"
    fill_field 'Name*', with: name; fill_field 'Password*', with: PASSWORD
    select 'Regular', from: 'Access'; fill_field 'Roles', with: 'e2e'
    click_button 'Save User'
    expect(page).to have_current_path('/admin/users', ignore_query: true)
    expect(find('.scrollable-container')).to have_content(name)
  end

  def create_link_item(resource, label, parent: nil)
    area(resource); type = resource == 'menu_items' ? 'Menu Item' : 'Footer Item'
    click_link "New #{type}"
    select 'Main', from: 'Menu Type' if resource == 'menu_items'
    { 'Label*'=>label, 'Icon'=>'/images/gear.svg', 'Options'=>'image-file', 'Link'=>'/admin', 'Access'=>'' }.each { |field, value| fill_field field, with: value }
    find(resource == 'menu_items' ? '#menu-order-field' : '#footer-order-field').set('50')
    select parent, from: resource == 'menu_items' ? 'Parent menu' : 'Parent footer' if parent
    click_button "Save #{type}"
    expect(page).to have_current_path("/admin/#{resource}", ignore_query: true)
    expect(find('.scrollable-container')).to have_content(label)
  end

  def create_blog(title = 'E2E Blog', content = 'E2E post content')
    area('blog_posts'); click_link 'New Blog'
    expect(page).to have_field('Author*', with: 'UI Test Admin')
    fill_field 'Title*', with: title; select 'Public', from: 'Visibility'; select 'Personal', from: 'Blog Type'
    quill(content); click_button 'Save Blog Post'
    expect(page).to have_current_path('/admin/blog_posts', ignore_query: true)
    expect(find('.scrollable-container')).to have_content(title)
    expect(find('.scrollable-container')).to have_content(content)
  end

  def create_image(name = 'e2e-image', group: 'E2E Gallery', order: 1)
    area('image_files'); click_link 'New Image'; fill_field 'Name*', with: name
    attach_file 'Upload Image*', Rails.root.join('spec/fixtures/files/sample.jpg')
    select 'JPEG', from: 'Mime Type'; find('#group-field').set(group); find('#slide-order-field').set(order.to_s)
    quill("Caption #{name}", index: 0); quill("Description #{name}", index: 1)
    click_button 'Save Image'
    expect(page).to have_current_path('/admin/image_files', ignore_query: true)
    expect(find('.scrollable-container')).to have_content(name)
  end

  def create_page(name = 'e2e-page', template: 'Text Only')
    area('pages'); click_link 'New page'
    replace_input('#name', name); replace_input('#title', "Title #{name}"); replace_input('#section', name); replace_input('#access', '')
    click_button 'New Section'; replace_input('#section_name', "#{name}-section")
    select template, from: 'section_templates'; quill("Content #{name}")
    click_button 'Generate Sections'; expect(page).to have_content("Content #{name}")
    click_button 'Save Page'; expect(page).to have_current_path('/admin/pages', ignore_query: true)
    expect(find('.scrollable-container')).to have_content(name)
  end

  def screenshot(name)
    page.save_screenshot(File.join(ENV.fetch('E2E_ARTIFACTS_DIR'), "#{name}.png"))
  end
end

Capybara.register_driver :admin_e2e_chrome do |app|
  if ENV['E2E_BROWSER'] == 'firefox'
    options = Selenium::WebDriver::Firefox::Options.new
    options.add_argument('-headless') unless ENV['E2E_HEADED'] == '1'
    options.binary = ENV['FIREFOX_BINARY'] if ENV['FIREFOX_BINARY']
    next Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
  end
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new') unless ENV['E2E_HEADED'] == '1'
  options.add_argument('--window-size=1440,1000')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument("--user-data-dir=#{File.join(ENV.fetch('E2E_ARTIFACTS_DIR'), 'chrome-profile')}")
  options.add_argument('--no-sandbox') if ENV['CI']
  options.binary = ENV['CHROME_BINARY'] if ENV['CHROME_BINARY']
  service = Selenium::WebDriver::Chrome::Service.new(args: ['--verbose'], log: File.join(ENV.fetch('E2E_ARTIFACTS_DIR'), 'chromedriver.log'))
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, service: service)
end
Capybara.app = Rails.application
Capybara.server = :puma, { Silent: true }
Capybara.default_driver = :admin_e2e_chrome
Capybara.javascript_driver = :admin_e2e_chrome
Capybara.default_max_wait_time = Integer(ENV.fetch('E2E_WAIT', '6'))
Capybara.save_path = ENV.fetch('E2E_ARTIFACTS_DIR')

RSpec.configure do |config|
  config.include AdminE2E, admin_e2e: true
  config.include Capybara::DSL, admin_e2e: true
  config.include Capybara::RSpecMatchers, admin_e2e: true
  config.order = :defined
  # Fail once at suite startup if the browser cannot launch, rather than retrying
  # it for every UI scenario and reporting misleading application failures.
  config.before(:suite) { Capybara.current_session.driver.browser } unless ARGV.include?('--dry-run')
  config.before(:each, admin_e2e: true) do
    Capybara.reset_sessions!; reset_empty_database!; bootstrap!
    Rails.application.routes.default_url_options[:host] = '127.0.0.1'
    Rails.application.routes.default_url_options[:port] = Capybara.current_session.server.port
    log_in unless self.class.metadata[:no_login]
  end
  config.after(:each, admin_e2e: true) do |example|
    if example.exception
      stem = example.full_description.gsub(/[^a-zA-Z0-9]+/, '-')[0, 160]
      File.write(File.join(ENV.fetch('E2E_ARTIFACTS_DIR'), "#{stem}.txt"), example.exception.full_message)
      begin
        screenshot(stem)
        page.save_page(File.join(ENV.fetch('E2E_ARTIFACTS_DIR'), "#{stem}.html"))
        File.write(File.join(ENV.fetch('E2E_ARTIFACTS_DIR'), "#{stem}.txt"), "#{page.current_url}\n#{example.exception.full_message}")
      rescue StandardError => error
        warn "Could not save browser artifacts: #{error.message}"
      end
    end
    if example.exception && example.exception.full_message.match?(/invalid session id|browser has closed the connection|disconnected: Unable to receive message/i)
      warn "Restarting disconnected browser before the next example; this example remains failed."
      Capybara.current_session.driver.quit
    end
    begin
      Capybara.reset_sessions!
    rescue Selenium::WebDriver::Error::InvalidSessionIdError
      warn "Browser session lost during cleanup; restarting before the next example."
      Capybara.current_session.driver.quit
    end
  end
  config.after(:suite) { Capybara.current_session.driver.quit }
end
