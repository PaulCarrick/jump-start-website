require 'rails_helper'

# Only administrators create accounts (Admin > Users); visitors cannot sign up.
RSpec.describe 'Account sign-up', type: :request do
  let!(:setup) { create(:site_setup) }

  it 'has no sign-up page or sign-up action' do
    expect { Rails.application.routes.recognize_path('/users/sign_up', method: :get) }.to raise_error(ActionController::RoutingError)
    expect { Rails.application.routes.recognize_path('/users', method: :post) }.to raise_error(ActionController::RoutingError)
    expect(User.devise_modules).not_to include(:registerable)
  end

  it 'still lets existing users sign in' do
    get new_user_session_path
    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include('Sign up')
  end
end
