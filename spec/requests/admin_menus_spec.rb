require 'rails_helper'

RSpec.describe 'Admin Menus screen', type: :request do
  let!(:setup) { create(:site_setup) }
  let(:admin) { create(:user, access: 'super') }
  let!(:first) { create(:menu_item, menu_type: 'Main', label: 'First', menu_order: 1, link: '/first') }
  let!(:second) { create(:menu_item, menu_type: 'Main', label: 'Second', menu_order: 2, link: '/second') }
  let!(:third) { create(:menu_item, menu_type: 'Main', label: 'Third', menu_order: 3, link: '/third') }
  let!(:admin_entry) { create(:menu_item, menu_type: 'Admin', label: 'Admin only', menu_order: 1, link: '/admin/x') }

  # The whole header tree as the page sends it, with some items changed.
  def header_tree(changes = {})
    MenuItem.where(menu_type: 'Main').order(:menu_order, :id).map do |item|
      { id: item.id, parent_id: changes.fetch(item.id, item.parent_id) }
    end
  end

  def send_order(items, kind: 'header')
    patch admin_menus_order_path, params: { kind: kind, items: items }, as: :json
  end

  before { sign_in admin }

  it 'shows the header tree without the Admin menu entries' do
    get admin_menus_path
    expect(response).to have_http_status(:ok)
    labels = Nokogiri::HTML(response.body).css('.admin-menu-label').map { |link| link.text.strip }
    expect(labels).to include('First', 'Second', 'Third')
    expect(labels).not_to include('Admin only')
  end

  it 'saves a new order and nesting as drafts' do
    items = header_tree(second.id => first.id)
    items.insert(0, items.delete(items.find { |entry| entry[:id] == third.id }))
    send_order(items)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['changed']).to be >= 2
    expect(MenuItem.find(third.id).menu_order).to eq(1)
    moved = MenuItem.find(second.id)
    expect(moved.parent_id).to eq(first.id)
    expect(moved.menu_order).to eq(1)
    expect(moved.temporal_state).to eq('draft') if moved.has_attribute?(:temporal_state)
  end

  it 'refuses a tree that is missing items' do
    send_order([ { id: first.id, parent_id: nil } ])
    expect(response).to have_http_status(:unprocessable_content)
    expect(MenuItem.find(first.id).menu_order).to eq(1)
  end

  it 'refuses a loop' do
    send_order(header_tree(first.id => second.id, second.id => first.id))
    expect(response).to have_http_status(:unprocessable_content)
  end

  it 'refuses more than two levels' do
    send_order(header_tree(second.id => first.id, third.id => second.id))
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body['error']).to include('2 levels')
    expect(MenuItem.find(third.id).parent_id).to be_nil
  end

  it 'refuses a parent from the other menu' do
    footer = create(:footer_item, label: 'Footer heading')
    send_order(header_tree(first.id => footer.id))
    expect(response).to have_http_status(:unprocessable_content)
  end

  it 'moves an item that links to /admin without changing it otherwise' do
    locked = create(:menu_item, menu_type: 'Main', label: 'Dashboard', menu_order: 4, link: '/admin')
    items = header_tree
    items.insert(0, items.delete(items.find { |entry| entry[:id] == locked.id }))
    send_order(items)
    expect(response).to have_http_status(:ok)
    expect(MenuItem.find(locked.id).menu_order).to eq(1)

    patch admin_menu_item_path(locked), params: { menu_item: { label: 'Changed' } }
    expect(MenuItem.find(locked.id).label).to eq('Dashboard')
  end

  it 'orders the footer, children included' do
    heading = create(:footer_item, label: 'Heading', footer_order: 1)
    child_a = create(:footer_item, label: 'A', parent_id: heading.id, footer_order: 1)
    child_b = create(:footer_item, label: 'B', parent_id: heading.id, footer_order: 2)
    items = FooterItem.order(:footer_order, :id).map { |item| { id: item.id, parent_id: item.parent_id } }
    index_a = items.index { |entry| entry[:id] == child_a.id }
    index_b = items.index { |entry| entry[:id] == child_b.id }
    items[index_a], items[index_b] = items[index_b], items[index_a]
    send_order(items, kind: 'footer')

    expect(response).to have_http_status(:ok)
    expect(FooterItem.find(heading.id).sub_items.map(&:label)).to eq(%w[B A])
  end

  it 'does not let other users change the order' do
    sign_in create(:user, access: 'read_only')
    send_order(header_tree(second.id => first.id))
    expect(response).to have_http_status(:forbidden)
    expect(MenuItem.find(second.id).parent_id).to be_nil
  end
end

RSpec.describe 'Settings test email', type: :request do
  let!(:setup) do
    create(:site_setup, smtp_server: '127.0.0.1', contact_email_from: 'site@example.com', contact_email_to: 'owner@example.com')
  end

  before { ActionMailer::Base.deliveries.clear }

  it 'sends a test message with the saved settings and returns to the Email tab' do
    sign_in create(:user, access: 'super')
    post admin_test_email_site_setup_path(setup)

    expect(response).to redirect_to(%r{/admin/site_setups/#{setup.id}/edit\?.*tab=email})
    expect(flash[:notice]).to include('owner@example.com')
    message = ActionMailer::Base.deliveries.last
    expect(message.to).to eq([ 'owner@example.com' ])
    expect(message.subject).to start_with('Test email from')
  end

  it 'reports a missing mail server instead of sending' do
    setup.update_columns(smtp_server: nil)
    sign_in create(:user, access: 'super')
    post admin_test_email_site_setup_path(setup)

    expect(flash[:error]).to include('mail server')
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  it 'is only for administrators' do
    sign_in create(:user, access: 'read_only')
    post admin_test_email_site_setup_path(setup)

    expect(response).to have_http_status(:forbidden).or have_http_status(:see_other)
    expect(ActionMailer::Base.deliveries).to be_empty
  end
end
