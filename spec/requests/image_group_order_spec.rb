require 'rails_helper'

# The media library's "Slide show order" strip saves a group's new order.
RSpec.describe 'Ordering the pictures of a group', type: :request do
  let!(:setup) { create(:site_setup) }
  let(:admin) { create(:user, access: 'super') }
  let!(:first) { create(:image_file, name: 'birds-1', group: 'birds', slide_order: 1) }
  let!(:second) { create(:image_file, name: 'birds-2', group: 'birds', slide_order: 2) }
  let!(:third) { create(:image_file, name: 'birds-3', group: 'birds', slide_order: 3) }
  let!(:elsewhere) { create(:image_file, name: 'fish-1', group: 'fish', slide_order: 1) }

  def order_of(*files) = files.map { |file| ImageFile.find(file.id).slide_order }

  it 'numbers the group 1, 2, 3 in the new order, as drafts' do
    sign_in admin
    patch admin_image_files_group_order_path, params: { group: 'birds', ids: [ third.id, first.id, second.id ] }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['changed']).to eq(3)
    expect(order_of(third, first, second)).to eq([ 1, 2, 3 ])
    expect(ImageFile.live_versions.find(first.id).slide_order).to eq(1)
    expect(Publishing.pending.map(&:id)).to contain_exactly(first.id, second.id, third.id)
    expect(order_of(elsewhere)).to eq([ 1 ])
  end

  it 'saves only the pictures whose place changed' do
    sign_in admin
    patch admin_image_files_group_order_path, params: { group: 'birds', ids: [ first.id, third.id, second.id ] }, as: :json
    expect(response.parsed_body['changed']).to eq(2)
    expect(Publishing.pending.map(&:id)).to contain_exactly(second.id, third.id)
  end

  it 'refuses a list that is not exactly the group' do
    sign_in admin
    [ [ first.id, second.id ], [ first.id, second.id, third.id, elsewhere.id ], [ first.id, first.id, second.id ] ].each do |ids|
      patch admin_image_files_group_order_path, params: { group: 'birds', ids: ids }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
    expect(Publishing.pending).to be_empty
  end

  it 'is only for administrators' do
    sign_in create(:user, access: 'read_only')
    patch admin_image_files_group_order_path, params: { group: 'birds', ids: [ third.id, first.id, second.id ] }, as: :json
    expect(response).to have_http_status(:forbidden)
    expect(order_of(first, second, third)).to eq([ 1, 2, 3 ])
  end

  it 'shows the strip and lists the grid in slide order when a group is chosen' do
    ImageFile.where(id: first.id).update_all(slide_order: 9)
    sign_in admin
    get admin_image_files_path('q[group_eq]' => 'birds')
    html = Nokogiri::HTML(response.body)
    expect(html.css('.admin-slide-strip .admin-slide').map { |item| item['data-name'] }).to eq(%w[birds-2 birds-3 birds-1])
    expect(html.css('.admin-media-grid .admin-media-name').map(&:text)).to eq(%w[birds-2 birds-3 birds-1])
    get admin_image_files_path(clear_search: true)
    expect(Nokogiri::HTML(response.body).css('.admin-slide-strip')).to be_empty
  end
end
