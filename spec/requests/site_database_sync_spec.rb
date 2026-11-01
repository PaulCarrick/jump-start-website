require 'rails_helper'

RSpec.describe 'Site database sync status', type: :request do
  let!(:setup) { create(:site_setup) }

  it 'reports content deployment separately from a synchronization failure and allows retry' do
    admin = create(:user, access: 'super')
    sign_in admin
    patch admin_site_setup_path(setup), params: { site_setup: { site_name: 'Changed website' } }
    allow_any_instance_of(SiteDatabaseProvisioner).to receive(:synchronize!).and_raise(SiteDatabaseProvisioner::Error, 'Database temporarily unavailable')
    post admin_deploy_publishing_path
    follow_redirect!
    expect(response.body).to include('Content deployed', 'Database temporarily unavailable', 'Retry Database Sync')
    expect(SiteSetup.live_versions.find_by(id: setup.id).site_name).to eq('Changed website')
    request = SiteDatabaseSyncRequest.last
    expect(request.status).to eq('failed')
    allow_any_instance_of(SiteDatabaseProvisioner).to receive(:synchronize!).and_return(true)
    post admin_retry_database_sync_path(request)
    expect(request.reload.status).to eq('completed')
  end

  it 'does not permit non-administrators to retry synchronization' do
    sign_in create(:user, access: 'read_only')
    request = SiteDatabaseSyncRequest.create!(deployment_id: 1, status: 'failed')
    post admin_retry_database_sync_path(request)
    expect(response).to redirect_to(root_path)
    expect(request.reload.status).to eq('failed')
  end
end
