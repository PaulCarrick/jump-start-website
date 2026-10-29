require 'rails_helper'

RSpec.describe 'Admin keyboard shortcuts', type: :system do
  let(:admin_user) { create(:user, access: 'super') }
  let!(:other_user) { create(:user) }

  before do
    driven_by(:selenium_chrome_headless)
    login_as(admin_user)
  end

  it 'adds a unique New shortcut and omits repeated row shortcuts' do
    visit admin_users_path
    expect(page).to have_css('a[accesskey="n"]', text: 'New User')
    expect(page).to have_no_css('.admin-main [accesskey="e"], .admin-main [accesskey="v"]')
  end

  it 'offers Save and Escape hints and cancels with Escape' do
    visit edit_admin_user_path(other_user)
    expect(page).to have_css('input[accesskey="s"]')
    expect(page).to have_css('a[aria-keyshortcuts="Escape"]', text: 'Cancel')
    page.driver.browser.action.send_keys(:escape).perform
    expect(page).to have_current_path(admin_users_path, ignore_query: true)
  end

  it 'does not assign Clear Sort when it is repeated' do
    visit admin_users_path
    page.execute_script(<<~JS)
      const panel = document.querySelector('.admin-main');
      panel.insertAdjacentHTML('beforeend', '<a class="btn" href="#">Clear Sort</a><a class="btn" href="#">Clear Sort</a>');
    JS
    expect(page).to have_no_css('.admin-main [accesskey="c"]')
  end
end
