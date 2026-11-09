require 'rails_helper'

# Settings > Appearance > Menu position: top (the default), left, right or bottom.
RSpec.describe 'The site menu position', type: :request do
  let!(:setup) { SiteSetup.find_by(configuration_name: 'default') || create(:site_setup) }
  let!(:page_record) { create(:page, name: 'garden', section: 'garden-content', title: 'Garden') }

  def body_class
    Nokogiri::HTML(response.body).at('body')['class']
  end

  def set_live(position)
    SiteSetup.unscoped.where(id: setup.id).update_all(menu_position: position)
  end

  it 'is top unless chosen, for new and existing setups' do
    expect(setup.reload.menu_position).to eq('top')
    expect(SiteSetup.new.menu_position).to eq('top')
    get page_path('garden')
    expect(body_class).to eq('site-menu-top')
  end

  it 'puts the published choice on every public page' do
    %w[left right bottom].each do |position|
      set_live(position)
      get page_path('garden')
      expect(body_class).to eq("site-menu-#{position}")
      get new_contact_path
      expect(body_class).to eq("site-menu-#{position}")
    end
  end

  it 'opens the dropdowns toward the page' do
    menu = create(:menu_item, menu_type: 'Main', label: 'Personal', link: '#', menu_order: 1)
    create(:menu_item, menu_type: 'Main', label: 'Family', link: '/family', parent_id: menu.id, menu_order: 1)
    { 'left' => 'dropend', 'right' => 'dropstart', 'bottom' => 'dropup' }.each do |position, direction|
      set_live(position)
      get page_path('garden')
      expect(Nokogiri::HTML(response.body).at('.site-menu .dropdown')['class']).to include(direction)
    end
  end

  it 'leaves the admin in its own frame' do
    set_live('left')
    sign_in create(:user, access: 'super')
    get admin_root_path
    expect(body_class).to eq('site-menu-top')
  end

  it 'refuses anything but top, left, right or bottom' do
    setup.menu_position = 'middle'
    expect(setup).not_to be_valid
    expect(setup.errors[:menu_position]).to be_present
    %w[top left right bottom].each do |position|
      setup.menu_position = position
      setup.valid?
      expect(setup.errors[:menu_position]).to be_empty
    end
  end

  it 'is saved from the Appearance tab as a draft, so visitors see it only once published' do
    sign_in create(:user, access: 'super')
    get edit_admin_site_setup_path(setup)
    form = Nokogiri::HTML(response.body)
    expect(form.css('input[type=radio][name="site_setup[menu_position]"]').map { |input| input['value'] }).to eq(%w[top left right bottom])
    expect(form.at('input[name="site_setup[menu_position]"][checked]')['value']).to eq('top')

    patch admin_site_setup_path(setup), params: { site_setup: { menu_position: 'right' } }
    expect(SiteSetup.find(setup.id).menu_position).to eq('right')
    expect(SiteSetup.live_versions.find(setup.id).menu_position).to eq('top')
  end
end
