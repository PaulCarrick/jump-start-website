require 'rails_helper'

RSpec.describe 'The admin link in the site header', type: :system do
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }

  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
    MenuItem.where(link: '/admin').delete_all
    create(:menu_item, menu_type: 'Main', label: 'Admin Dashboard', link: '/admin', icon: '/images/gear.svg', options: 'image-file', menu_order: 6)
    create(:menu_item, menu_type: 'Main', label: 'Contact', link: '/contacts/new', menu_order: 4)
  end

  # The test window is narrow, so the header menu sits behind its toggle.
  def open_header_menu
    find('.navbar-toggler').click if page.has_css?('.navbar-toggler', visible: true, wait: 1)
  end

  # Clicking the gear picture used to send this tab to "undefined" (a header
  # script followed the picture's missing href) while the admin opened.
  it 'opens the admin in a new tab and leaves this page where it is' do
    visit new_contact_path
    open_header_menu
    admin = window_opened_by { find('header a[href="/admin"] img').click }
    within_window(admin) { expect(page).to have_current_path(%r{\A/admin}) }
    expect(page).to have_current_path(new_contact_path)
    admin.close
  end

  it 'still follows ordinary header links in the same tab' do
    visit new_contact_path
    open_header_menu
    find('header a.nav-link', text: /contact/i).click
    expect(page).to have_current_path(new_contact_path)
  end
end
