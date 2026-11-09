require 'rails_helper'

RSpec.describe 'Page workspace', type: :request do
  let!(:setup) { create(:site_setup) }
  let(:admin) { create(:user, access: 'super') }
  let!(:page_record) { create(:page, name: 'garden', section: 'garden-content') }
  let!(:first) { create(:section, page: page_record, content_type: 'garden-content', section_name: 'one', section_order: 10) }
  let!(:second) { create(:section, page: page_record, content_type: 'garden-content', section_name: 'two', section_order: 20) }
  let!(:cell_a) { create(:cell, section: first, section_name: 'one', cell_name: 'a', cell_order: 1) }
  let!(:cell_b) { create(:cell, section: first, section_name: 'one', cell_name: 'b', cell_order: 2) }
  let!(:cell_c) { create(:cell, section: second, section_name: 'two', cell_name: 'c', cell_order: 1) }

  def send_order(sections)
    patch admin_page_order_path(page_record), params: { sections: sections }, as: :json
  end

  before { sign_in admin }

  it 'shows the page with its sections and columns' do
    get admin_page_workspace_path(page_record, cell: cell_b.id)
    expect(response).to have_http_status(:ok)
    document = Nokogiri::HTML(response.body)
    expect(document.css('.outline-section > .outline-row .outline-label').map { |link| link.text.strip }).to eq(%w[one two])
    expect(document.at_css('.workspace-panel [data-react-class="CellEditor"]')).to be_present
    expect(document.at_css('.outline-cell.is-selected')['data-id']).to eq(cell_b.id.to_s)
  end

  it 'saves the new order of sections and of columns within a section' do
    send_order([ { id: second.id, cells: [ cell_c.id ] }, { id: first.id, cells: [ cell_b.id, cell_a.id ] } ])

    expect(response).to have_http_status(:ok)
    expect(Section.find(second.id).section_order).to eq(10)
    expect(Section.find(first.id).section_order).to eq(20)
    expect(Cell.find(cell_b.id).cell_order).to eq(1)
    expect(Cell.find(cell_a.id).cell_order).to eq(2)
    expect(page_record.ordered_sections.map(&:section_name)).to eq(%w[two one])
  end

  it 'refuses to move a column into another section' do
    send_order([ { id: first.id, cells: [ cell_a.id, cell_b.id, cell_c.id ] }, { id: second.id, cells: [] } ])
    expect(response).to have_http_status(:unprocessable_content)
    expect(Cell.find(cell_c.id).section_id).to eq(second.id)
  end

  it 'refuses a list that leaves a section out' do
    send_order([ { id: first.id, cells: [ cell_a.id, cell_b.id ] } ])
    expect(response).to have_http_status(:unprocessable_content)
  end

  it 'adds an empty text column at the end of a section' do
    post admin_page_section_columns_path(page_record, first.id)
    added = Cell.where(section_id: first.id).order(:cell_order).last
    expect(added.cell_order).to eq(3)
    expect(added.section_name).to eq('one')
    expect(response).to redirect_to(admin_page_workspace_path(page_record, cell: added.id))
  end

  it 'does not let other users reorder or add columns' do
    sign_in create(:user, access: 'read_only')
    send_order([ { id: second.id, cells: [ cell_c.id ] }, { id: first.id, cells: [ cell_a.id, cell_b.id ] } ])
    expect(response).to have_http_status(:forbidden)
    post admin_page_section_columns_path(page_record, first.id)
    expect(response).to have_http_status(:forbidden)
    expect(Section.find(first.id).section_order).to eq(10)
    expect(Cell.where(section_id: first.id).count).to eq(2)
  end

  it 'returns from the section editor to the workspace' do
    get edit_admin_section_path(first, return_url: admin_page_workspace_path(page_record, section: first.id))
    expect(response.body).to include(admin_page_workspace_path(page_record, section: first.id))
  end
end
