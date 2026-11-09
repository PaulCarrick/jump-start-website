require 'rails_helper'

RSpec.describe 'Publishing UI and authorization', type: :request do
  let!(:setup) { create(:site_setup) }

  it 'requires administrator access to deploy or discard' do
    sign_in create(:user, access: 'read_only')
    post admin_deploy_publishing_path
    expect(response).to have_http_status(:forbidden)
    post admin_discard_publishing_path
    expect(response).to have_http_status(:forbidden)
  end

  it 'saves drafts through existing editors and deploys them from the shared review page' do
    sign_in create(:user, access: 'super')
    record = create(:page, title: 'Public title')
    patch admin_page_path(record), params: { page: { title: 'Pending title' } }
    get page_path(record.name)
    expect(response.body).not_to include('Pending title')
    get admin_publishing_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Review and publish', 'Preview draft', 'Public title', 'Pending title')
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

RSpec.describe 'Publishing chosen groups from the review page', type: :request do
  let!(:setup) { create(:site_setup) }
  let!(:garden) { create(:page, name: 'garden', title: 'Garden') }
  let!(:kitchen) { create(:page, name: 'kitchen', title: 'Kitchen') }

  before do
    sign_in create(:user, access: 'super')
    patch admin_page_path(garden), params: { page: { title: 'Our Garden' } }
    patch admin_page_path(kitchen), params: { page: { title: 'Our Kitchen' } }
  end

  # The checkboxes and the list of reviewed changes, as the page sends them.
  def review_form
    get admin_publishing_path
    document = Nokogiri::HTML(response.body)
    {
      groups: document.css('input[name="groups[]"]').to_h { |box| [ box.parent.text.squish, box['value'] ] },
      reviewed: document.css('input[name="reviewed[]"]').map { |field| field['value'] }
    }
  end

  it 'publishes the ticked group, records what it contained and leaves the other' do
    form = review_form
    expect(form[:groups].keys).to eq([ 'Our Garden', 'Our Kitchen' ])
    post admin_deploy_publishing_path, params: { groups: [ form[:groups]['Our Garden'] ], reviewed: form[:reviewed], summary: 'Garden only' }

    expect(flash[:notice]).to include('Our Garden (1 change)', '1 change is still waiting')
    expect(Page.live_versions.find_by(id: garden.id).title).to eq('Our Garden')
    expect(Page.live_versions.find_by(id: kitchen.id).title).to eq('Kitchen')
    expect(Deployment.last).to have_attributes(summary: 'Garden only', contents: 'Our Garden (1 change)')
    follow_redirect!
    expect(response.body).to include('Our Garden (1 change)', 'Garden only')
  end

  it 'publishes nothing when a ticked group changed after the page was opened' do
    form = review_form
    patch admin_page_path(garden), params: { page: { title: 'Our Lovely Garden' } }
    post admin_deploy_publishing_path, params: { groups: [ form[:groups]['Our Garden'] ], reviewed: form[:reviewed] }

    expect(flash[:alert]).to include('Review them again')
    expect(Page.live_versions.find_by(id: garden.id).title).to eq('Garden')
    expect(Deployment.count).to eq(0)
  end

  it 'asks for at least one group' do
    form = review_form
    post admin_deploy_publishing_path, params: { reviewed: form[:reviewed] }
    expect(flash[:alert]).to include('Tick at least one group')
    expect(Publishing.pending.size).to eq(2)
  end

  it 'discards only the ticked group' do
    form = review_form
    post admin_discard_publishing_path, params: { groups: [ form[:groups]['Our Kitchen'] ], reviewed: form[:reviewed] }

    expect(flash[:notice]).to include('Discarded: Our Kitchen (1 change)')
    expect(Publishing.pending.map(&:id)).to eq([ garden.id ])
  end
end
