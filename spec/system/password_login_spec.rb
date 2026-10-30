require 'rails_helper'

RSpec.describe 'Password login form', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  it 'signs in through the browser and retains the authenticated session' do
    user = create(:user, access: 'super', password: 'Login-test-password-123', password_confirmation: 'Login-test-password-123')
    visit new_user_session_path
    fill_in 'Email Address', with: user.email
    fill_in 'Password', with: 'Login-test-password-123'
    click_button 'Log in'
    expect(page).to have_no_current_path(new_user_session_path, ignore_query: true)
    visit admin_publishing_path
    expect(page).to have_content('Deploy Changes')
    expect(page).to have_no_button('Log in')
  end
end
