require 'rails_helper'

RSpec.describe 'Public dropdown menu order', type: :request do
  it 'renders deployed children by menu order rather than label or creation order' do
    create(:site_setup)
    create(:page, name: 'home')
    parent = create(:menu_item, menu_type: 'Main', label: 'Professional', parent_id: nil, menu_order: 1, link: '#')
    { 'Blogs' => 4, 'Employment' => 2, 'Overview' => 1, 'Portfolio' => 3 }.each do |label, order|
      create(:menu_item, menu_type: 'Main', parent: parent, label: label, menu_order: order, link: "/#{label.downcase}")
    end
    get '/home'
    expect(response).to have_http_status(:ok)
    menu = Nokogiri::HTML(response.body).css('.dropdown-menu .dropdown-item').map { |link| link.text.strip }
    expect(menu).to eq(%w[Overview Employment Portfolio Blogs])
  end
end
