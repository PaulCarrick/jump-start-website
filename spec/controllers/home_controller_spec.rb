require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe "GET #index" do
    it "redirects to the home page" do
      get :index
      expect(response).to redirect_to(page_path("home"))
    end

    it "returns a 302 redirect status" do
      get :index
      expect(response).to have_http_status(:found) # 302 HTTP status
    end
  end
end
