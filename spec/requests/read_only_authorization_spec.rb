require 'rails_helper'

RSpec.describe 'Read-only write protection', type: :request do
  let!(:setup) { create(:site_setup) }
  let!(:reader) { create(:user, access: 'read_only') }
  let!(:page) { create(:page) }
  let!(:section) { create(:section, content_type: page.section) }
  let!(:blog) { create(:blog_post) }
  let!(:comment) { create(:post_comment, blog_post: blog) }

  before { sign_in reader }

  it 'blocks section deletion through a crafted editor cancellation URL' do
    get edit_admin_page_path(page), params: { canceled: 'true', new_section: 'true', section_id: section.id }
    expect(response).to have_http_status(:forbidden)
    expect(Section.unscoped.where(id: section.id)).to exist
  end

  it 'blocks section creation through the Add Section link and deletion' do
    expect { get "/admin/page/new_section/#{page.id}" }.not_to change(Section.unscoped, :count)
    expect(response).to have_http_status(:forbidden)
    delete "/admin/sections/#{section.id}"
    expect(response).to have_http_status(:forbidden)
    expect(Section.unscoped.where(id: section.id)).to exist
  end

  %w[blog_posts post_comments].each do |resource|
    it "blocks all #{resource} API mutations without changing live content" do
      record = resource == 'blog_posts' ? blog : comment
      model = record.class
      key = resource.singularize
      original = record.attributes
      expect do
        post "/api/v1/#{resource}", params: { key => original.except('id').merge('title' => 'Unauthorized') }
        expect(response).to have_http_status(:forbidden)
      end.not_to change(model.unscoped, :count)
      patch "/api/v1/#{resource}/#{record.id}", params: { key => { title: 'Unauthorized' } }
      expect(response).to have_http_status(:forbidden)
      delete "/api/v1/#{resource}/#{record.id}"
      expect(response).to have_http_status(:forbidden)
      expect(model.live_versions.find_by!(id: record.id).title).to eq(original['title'])
    end
  end

  it 'still permits read-only users to view editors and public blog content' do
    get edit_admin_page_path(page)
    expect(response).to have_http_status(:ok)
    get "/api/v1/blog_posts/#{blog.id}"
    expect(response).to have_http_status(:ok)
  end

  it 'rejects unauthenticated blog mutations' do
    sign_out reader
    patch "/api/v1/blog_posts/#{blog.id}", params: { blog_post: { title: 'Unauthorized' } }
    expect(response).to have_http_status(:forbidden)
  end

  it 'preserves blog-capable users ability to edit posts' do
    sign_out reader
    sign_in create(:user, access: 'blogs')
    patch "/api/v1/blog_posts/#{blog.id}", params: { blog_post: { title: 'Authorized' } }
    expect(response).to have_http_status(:ok)
    expect(BlogPost.live_versions.find_by!(id: blog.id).title).to eq('Authorized')
  end
end
