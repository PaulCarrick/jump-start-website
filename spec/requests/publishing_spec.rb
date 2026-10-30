require 'rails_helper'

RSpec.describe 'Publishing UI and authorization', type: :request do
  let!(:setup) { create(:site_setup) }

  it 'requires administrator access to deploy or discard' do
    sign_in create(:user, access: 'read_only')
    post admin_deploy_publishing_path
    expect(response).to redirect_to(root_path)
    post admin_discard_publishing_path
    expect(response).to redirect_to(root_path)
  end

  it 'saves drafts through existing editors and deploys them from the shared review page' do
    sign_in create(:user, access: 'super')
    record = create(:page, title: 'Public title')
    patch admin_page_path(record), params: { page: { title: 'Pending title' } }
    get page_path(record.name)
    expect(response.body).not_to include('Pending title')
    get admin_publishing_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Deploy Changes', 'Preview Draft')
    post admin_deploy_publishing_path, params: { summary: 'Review complete' }
    expect(response).to redirect_to(admin_publishing_path)
    expect(Deployment.last.summary).to eq('Review complete')
    get admin_publishing_history_path(model: 'Page', record_id: record.id)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Recorded period')
  end
  it 'rejects a stale browser payload instead of overwriting the current draft' do
    sign_in create(:user, access: 'super')
    record = create(:page, title: 'Original')
    original_payload = { version: record.version, updated_at: record.updated_at.iso8601(6) }
    patch admin_page_path(record), params: { page: original_payload.merge(title: 'First draft') }
    patch admin_page_path(record), params: { page: original_payload.merge(title: 'Outdated draft') }
    expect(Page.find(record.id).title).to eq('First draft')
    expect(response).to have_http_status(:see_other)
  end

  it 'keeps large database failures out of the session cookie' do
    sign_in create(:user, access: 'super')
    allow(Publishing).to receive(:deploy!).and_raise(ActiveRecord::StatementInvalid, 'private row contents ' * 1000)
    post admin_deploy_publishing_path
    expect(response).to redirect_to(admin_publishing_path)
    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Your drafts are still available')
    expect(response.body).not_to include('private row contents')
  end
end
