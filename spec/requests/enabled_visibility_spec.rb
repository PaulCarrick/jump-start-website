require 'rails_helper'

RSpec.describe 'Enabled content visibility', type: :request do
  let!(:setup) { create(:site_setup) }
  let!(:record) { create(:page) }
  let!(:section) { create(:section, page: record, content_type: record.section) }
  let!(:visible_cell) { create(:cell, section: section, image: nil, link: nil, content: '<p>Visible draft content</p>') }
  let!(:hidden_cell) { create(:cell, section: section, image: nil, link: nil, enabled: false, content: '<p>Hidden draft content</p>') }

  it 'defaults all editable records to enabled and retains timestamps' do
    [BlogPost, Cell, Contact, FooterItem, ImageFile, MenuItem, Page, PostComment, Section, SiteSetup, User].each do |model|
      expect(model.new.enabled).to be(true)
      expect(model.column_names).to include('created_at', 'updated_at')
    end
  end

  it 'omits disabled cells and sections from the public page, retaining them in admin' do
    get page_path(record.name)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Visible draft content')
    expect(response.body).not_to include('Hidden draft content')
    section.update!(enabled: false)
    get page_path(record.name)
    expect(response.body).not_to include('Visible draft content')
    sign_in create(:user, access: 'super')
    get admin_cells_path
    expect(response.body).to include(hidden_cell.cell_name)
    get admin_section_path(section)
    expect(response.body).to include('Hidden draft content')
  end

  it 'returns not found for a disabled public page while keeping it editable' do
    record.update!(enabled: false)
    get page_path(record.name)
    expect(response).to have_http_status(:not_found)
    sign_in create(:user, access: 'super')
    get edit_admin_page_path(record)
    expect(response).to have_http_status(:ok)
  end
end

RSpec.describe 'Enabled nested saves and navigation', type: :request do
  let!(:setup) { create(:site_setup) }

  before { sign_in create(:user, access: 'super') }

  it 'persists enabled=false through the nested page JSON endpoint' do
    record = create(:page)
    section = create(:section, page: record)
    cell = create(:cell, section: section, image: nil, link: nil)
    patch "/api/v1/pages/#{record.id}", params: {
      page: { enabled: false, sections_attributes: [
        { id: section.id, enabled: false, cells_attributes: [{ id: cell.id, enabled: false }] }
      ] }
    }, as: :json
    expect(response).to have_http_status(:ok)
    expect(record.reload.enabled).to be(false)
    expect(section.reload.enabled).to be(false)
    expect(cell.reload.enabled).to be(false)
  end

  it 'excludes disabled media from public lookups while preserving admin lookups' do
    image = create(:image_file, enabled: false)
    get '/api/v1/image_files', params: { q: { name_eq: image.name }, public_view: true }
    expect(response.parsed_body).to eq([])
    get '/api/v1/image_files', params: { q: { name_eq: image.name } }
    expect(response.parsed_body.map { |row| row.fetch('id') }).to include(image.id)
  end

  it 'filters disabled navigation and links associated with disabled pages' do
    record = create(:page, enabled: false)
    hidden = create(:menu_item, menu_type: 'Main', label: 'Hidden navigation', enabled: false)
    page_link = create(:menu_item, menu_type: 'Main', label: 'Disabled page navigation', page: record)
    expect(MenuItem.publicly_enabled).not_to include(hidden, page_link)
    expect(MenuItem.all).to include(hidden, page_link)
  end
end
