require 'rails_helper'

RSpec.describe 'Login with temporal users', type: :request do
  let!(:setup) { create(:site_setup) }

  it 'accepts a password and retains the session on the following request' do
    user = create(:user, access: 'super', password: 'Login-test-password-123', password_confirmation: 'Login-test-password-123')
    post user_session_path, params: { user: { email: user.email, password: 'Login-test-password-123' } }
    expect(response).to have_http_status(:redirect)
    get admin_publishing_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Deploy Changes')
  end
end
