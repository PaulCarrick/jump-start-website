require 'rails_helper'

RSpec.describe 'Editing a page from the public site', type: :request do
  let!(:setup) { create(:site_setup) }
  let(:admin) { create(:user, access: 'super') }
  let!(:page_record) { create(:page, name: 'garden', section: 'garden-content', title: 'Garden') }
  let!(:section) { create(:section, page: page_record, content_type: 'garden-content', section_name: 'garden-intro') }
  let!(:column) { create(:cell, section: section, section_name: 'garden-intro', content: '<p>Roses</p>', image: nil, link: nil) }
  let!(:other_page) { create(:page, name: 'kitchen', title: 'Kitchen') }

  # An edit as the admin screens make it: a draft.
  def edit_draft(record, attributes)
    PublishingContext.set(editing: true, deploying: false, live: false, preview: false) { record.class.find(record.id).update!(attributes) }
  end

  def live(record)
    record.class.live_versions.find_by(id: record.id)
  end

  before { sign_in admin }

  it 'shows Edit Page to administrators, and the editing bar once started' do
    get page_path('garden')
    expect(Nokogiri::HTML(response.body).at('.page-edit-bar button').text.strip).to eq('Edit Page')

    post admin_page_editing_start_path(page_record)
    expect(response).to redirect_to(page_path('garden', preview: 'draft', editing: 1))
    follow_redirect!
    document = Nokogiri::HTML(response.body)
    expect(document.at('.page-edit-bar').text.squish).to include('Editing… Save Changes', 'Cancel')
    expect(document.at('[data-controller="page-editing"]')['data-page-editing-workspace-value']).to eq(admin_page_workspace_path(page_record))
    expect(document.at("[data-section-id='#{section.id}']")).to be_present
  end

  it 'publishes only the changes made since editing started' do
    edit_draft(other_page, title: 'Our Kitchen')
    post admin_page_editing_start_path(page_record)
    edit_draft(column, content: '<p>Tulips</p>')
    edit_draft(page_record, title: 'Our Garden')

    get page_path('garden', preview: 'draft', editing: 1)
    expect(Nokogiri::HTML(response.body).at('.page-edit-save').text.squish).to include('Save Changes (2)')
    expect(response.body).to include('1 other change is waiting from before')

    post admin_page_editing_save_path(page_record)

    expect(response).to redirect_to(page_path('garden'))
    expect(flash[:notice]).to include('Published: Our Garden (2 changes)')
    expect(live(column).content).to include('Tulips')
    expect(live(page_record).title).to eq('Our Garden')
    expect(live(other_page).title).to eq('Kitchen')
    expect(Publishing.pending.map(&:id)).to eq([ other_page.id ])
    expect(Deployment.last.contents).to eq('Our Garden (2 changes)')
  end

  it 'discards only the changes made since editing started' do
    edit_draft(other_page, title: 'Our Kitchen')
    post admin_page_editing_start_path(page_record)
    edit_draft(column, content: '<p>Tulips</p>')

    post admin_page_editing_cancel_path(page_record)

    expect(flash[:notice]).to include('Discarded 1 change')
    PublishingContext.set(editing: true, deploying: false, live: false, preview: false) do
      expect(Cell.find(column.id).content).to include('Roses')
    end
    expect(Publishing.pending.map(&:id)).to eq([ other_page.id ])
  end

  it 'carries on with the same session when Edit Page is pressed again' do
    post admin_page_editing_start_path(page_record)
    edit_draft(column, content: '<p>Tulips</p>')
    post admin_page_editing_start_path(page_record)
    post admin_page_editing_save_path(page_record)
    expect(live(column).content).to include('Tulips')
  end

  it 'opens the media library on the picture a page shows' do
    image = create(:image_file, name: 'rose')
    get admin_locate_image_file_path(src: "http://www.example.com#{image.image_url}")
    expect(response).to redirect_to(admin_image_files_path(clear_search: true, selected: image.id))

    get admin_locate_image_file_path(src: 'http://www.example.com/images/gear.svg')
    expect(response).to redirect_to(admin_image_files_path)
  end

  it 'opens admin links in the header and footer in a new tab' do
    create(:menu_item, menu_type: 'Main', label: 'Admin Dashboard', link: '/admin', icon: '/images/gear.svg', options: 'image-file')
    create(:menu_item, menu_type: 'Main', label: 'Family', link: '/family')
    get page_path('garden')
    document = Nokogiri::HTML(response.body)
    expect(document.at('header a[href="/admin"]')['target']).to eq('_blank')
    expect(document.at('header a[href="/family"]')['target']).to eq('_self')
  end

  it 'is only for administrators' do
    sign_in create(:user, access: 'read_only')
    post admin_page_editing_start_path(page_record)
    expect(response).to have_http_status(:forbidden)
    get page_path('garden')
    expect(response.body).not_to include('Edit Page')
  end
end
