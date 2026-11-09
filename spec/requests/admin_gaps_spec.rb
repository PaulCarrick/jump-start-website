require 'rails_helper'

# Admin fields found missing when paul-carrick.com was rebuilt from scratch.
RSpec.describe 'Admin fields from the rebuild', type: :request do
  let!(:setup) { create(:site_setup) }
  let(:admin) { create(:user, access: 'super') }
  let!(:page_record) { create(:page, name: 'garden', section: 'garden-content') }
  let!(:section) { create(:section, page: page_record, content_type: 'garden-content', section_name: 'new-section_7') }
  let!(:column) { create(:cell, section: section, section_name: 'new-section_7', cell_name: 'garden-text', width: 'auto') }

  before { sign_in admin }

  it 'renames a section from the workspace panel, and its columns with it' do
    get admin_page_workspace_path(page_record, section: section.id)
    expect(Nokogiri::HTML(response.body).at('input[name="section[section_name]"]')['value']).to eq('new-section_7')

    patch admin_section_path(section), params: { section: { section_name: 'garden-intro' }, return_url: admin_page_workspace_path(page_record, section: section.id) }

    expect(response).to redirect_to(admin_page_workspace_path(page_record, section: section.id))
    expect(Section.find(section.id).section_name).to eq('garden-intro')
    expect(Cell.find(column.id).section_name).to eq('garden-intro')
  end

  it 'refuses a section name that cannot be an anchor' do
    patch admin_section_path(section), params: { section: { section_name: 'bad<name>' } }
    expect(Section.find(section.id).section_name).to eq('new-section_7')
  end

  it 'keeps a column width that is auto or a size, and refuses anything else' do
    expect(column.update(width: '100%')).to be(true)
    expect(column.update(width: '300px')).to be(true)
    expect(column.update(width: 'auto')).to be(true)
    expect(column.update(width: 'calc(100% - 1px)')).to be(false)
    expect(column.errors[:width]).to be_present
  end

  it 'saves the posted date chosen on the blog form' do
    get new_admin_blog_post_path
    expect(Nokogiri::HTML(response.body).at('input[type="datetime-local"][name="blog_post[posted]"]')).to be_present

    post admin_blog_posts_path, params: { blog_post: { author: 'Paul Carrick', title: 'Website Upgraded', visibility: 'Public', blog_type: 'Professional',
                                                       content: '<p>Notes</p>', posted: '2026-10-28T22:16:54' }, return_url: admin_blog_posts_path }

    expect(BlogPost.find_by!(title: 'Website Upgraded').posted.utc.iso8601).to eq('2026-10-28T22:16:54Z')
    get edit_admin_blog_post_path(BlogPost.find_by!(title: 'Website Upgraded'))
    expect(Nokogiri::HTML(response.body).at('input[name="blog_post[posted]"]')['value']).to eq('2026-10-28T22:16:54')
  end

  it 'saves nothing when the section editor sends a section without columns' do
    patch "/api/v1/sections/#{section.id}", params: { section: { section_name: 'renamed', cells_attributes: [ { id: column.id, _destroy: '1' } ] } }, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(Section.find(section.id).section_name).to eq('new-section_7')
    expect(Cell.where(id: column.id)).to exist
  end
end
