require 'rails_helper'

RSpec.describe 'Blog comment ownership and cleaning', type: :request do
  let!(:setup) { create(:site_setup) }
  let!(:blog) { create(:blog_post) }
  let!(:writer) { create(:user, name: 'Writer', access: 'regular') }
  let!(:other_visitor) { create(:user, name: 'Other Visitor', access: 'regular') }
  let!(:administrator) { create(:user, name: 'Administrator', access: 'admin') }
  let!(:older_comment) { create(:post_comment, id: 500, blog_post: blog, author: 'Paul Carrick', content: '<p>I agree.</p>') }

  def live_comment(id)
    PostComment.live_versions.find_by(id: id)
  end

  def write_comment(content)
    post '/api/v1/post_comments', params: { post_comment: {
      blog_post_id: blog.id, title: 'Visitor comment', author: 'Paul Carrick', posted: '2000-01-01', enabled: false, content: content
    } }
    expect(response).to have_http_status(:created)
    live_comment(JSON.parse(response.body)['id'])
  end

  it 'records the signed-in writer and ignores the author, date and enabled flag sent by a visitor' do
    sign_in writer
    comment = write_comment('<p>Hello</p>')

    expect(comment.user_id).to eq(writer.id)
    expect(comment.author).to eq('Writer')
    expect(comment.posted.year).to eq(Time.current.year)
    expect(comment.enabled).to be(true)
  end

  it 'removes scripts, event handlers and javascript links but keeps formatting' do
    sign_in writer
    comment = write_comment(
      '<p>Hi <strong>there</strong></p><img src=x onerror=alert(1)><script>alert(2)</script>' \
      '<a href="javascript:alert(3)">bad</a><a href="https://example.com" onclick="steal()">good</a>'
    )

    expect(comment.content).to include('<strong>there</strong>', '<a href="https://example.com">good</a>')
    expect(comment.content).not_to include('<img', '<script', 'onerror', 'onclick', 'javascript:')
  end

  it 'refuses changes and deletion by anyone but the writer' do
    sign_in writer
    comment = write_comment('<p>Mine</p>')
    sign_out writer

    sign_in other_visitor
    patch "/api/v1/post_comments/#{comment.id}", params: { post_comment: { content: '<p>Changed by someone else</p>' } }
    expect(response).to have_http_status(:forbidden)
    delete "/api/v1/post_comments/#{comment.id}"
    expect(response).to have_http_status(:forbidden)

    expect(live_comment(comment.id).content).to eq('<p>Mine</p>')
  end

  it 'lets the writer edit their own comment without changing its author' do
    sign_in writer
    comment = write_comment('<p>First</p>')

    patch "/api/v1/post_comments/#{comment.id}", params: { post_comment: { content: '<p>Second</p>', author: 'Paul Carrick' } }
    expect(response).to have_http_status(:ok)
    expect(live_comment(comment.id).content).to eq('<p>Second</p>')
    expect(live_comment(comment.id).author).to eq('Writer')
  end

  it 'protects comments written before writers were recorded from regular users' do
    sign_in other_visitor
    patch "/api/v1/post_comments/#{older_comment.id}", params: { post_comment: { content: '<p>Edited by a visitor</p>' } }
    expect(response).to have_http_status(:forbidden)
    delete "/api/v1/post_comments/#{older_comment.id}"
    expect(response).to have_http_status(:forbidden)
    expect(live_comment(older_comment.id).content).to eq('<p>I agree.</p>')
  end

  it 'lets an administrator delete any comment (as a draft until deployed, like other admin changes)' do
    sign_in administrator
    delete "/api/v1/post_comments/#{older_comment.id}"
    expect(response).to have_http_status(:ok)
    expect(PostComment.unscoped.where(id: older_comment.id, temporal_state: 'draft', temporal_deleted: true)).to exist
  end
end
