require 'rails_helper'

RSpec.describe 'Header and footer links', type: :request do
  let!(:setup) { create(:site_setup) }
  let!(:public_page) { create(:page, name: 'home', title: 'Home', section: 'Home') }

  before do
    create(:menu_item, menu_type: 'Main', label: 'Admin Dashboard', link: '/admin', menu_order: 1)
    create(:menu_item, menu_type: 'Main', label: 'Login', link: '/users/sign_in', menu_order: 2)
    other = create(:footer_item, label: 'Other', link: nil, footer_order: 1)
    create(:footer_item, label: 'Admin Dashboard', link: '/admin', footer_order: 1, parent_id: other.id)
    create(:footer_item, label: 'Login', link: '/users/sign_in', footer_order: 2, parent_id: other.id)
  end

  def links_on_home
    get '/home'
    Nokogiri::HTML(response.body).css('a').map { |link| link['href'] }
  end

  it 'shows visitors no links into the admin area' do
    links = links_on_home
    expect(links).not_to include('/admin')
    expect(links).to include('/users/sign_in')
  end

  it 'shows Log out instead of Login in the header and footer once signed in' do
    sign_in create(:user, name: 'Reader', access: 'regular')
    links = links_on_home
    expect(links).not_to include('/users/sign_in')
    expect(links.count('/users/sign_out')).to eq(2)
    expect(links).not_to include('/admin')
  end

  it 'shows the admin links to users who can use the admin area' do
    sign_in create(:user, name: 'Reader', access: 'read_only')
    expect(links_on_home.count('/admin')).to eq(2)
  end

  it 'gives the contact form the simple editor toolbar' do
    get new_contact_path
    editor = Nokogiri::HTML(response.body).at_css('[data-react-class="HtmlEditor"]')
    expect(JSON.parse(editor['data-react-props'])['simpleToolbar']).to be(true)
  end
end
