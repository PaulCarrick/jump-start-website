require "rails_helper"

RSpec.describe "Missing public pages", type: :request do
  it "renders the site shell and a not-found response" do
    get page_path("no-such-page")
    expect(response).to have_http_status(:not_found)
    expect(Nokogiri::HTML(response.body).text).to include("Can't find page for: no-such-page.")
  end
end
