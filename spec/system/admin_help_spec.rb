require 'rails_helper'

RSpec.describe 'Admin Help', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  it 'opens the complete guide from the bottom of the sidebar and follows topic links' do
    login_as(create(:user, access: 'super'))
    visit admin_pages_path
    within('.admin-sidebar') do
      expect(page).to have_css('ul.navbar-nav > li:last-child a', text: /help/i)
      find("a[href='/admin/help']").click
    end
    expect(page).to have_current_path(admin_help_path)
    expect(page).to have_css('h1', text: 'Admin user guide')
    expect(page).to have_css('#keyboard-shortcuts', text: 'Keyboard shortcuts')
    expect(page.evaluate_script(<<~JS)).to be(true)
      Array.from(document.querySelectorAll('.admin-help a[href^="#"]')).every(link =>
        document.getElementById(decodeURIComponent(link.hash.slice(1))))
    JS
    within('.admin-help') { click_link 'Pages', exact: true }
    expect(page).to have_current_path(%r{/admin/help\#pages\z}, url: true)
    expect(page).to have_css('#common-questions')
    page.save_screenshot(Rails.root.join('tmp/admin-help.png'))
  end

  it 'allows a read-only user to read the guide' do
    login_as(create(:user, access: 'read_only'))
    visit admin_help_path
    expect(page).to have_css('h1', text: 'Admin user guide')
  end

  it 'redirects regular users away from admin help' do
    login_as(create(:user, access: 'regular'))
    visit admin_help_path
    expect(page).to have_no_css('.admin-help')
    expect(page).to have_current_path(%r{\A/(home)?\z})
  end
end
