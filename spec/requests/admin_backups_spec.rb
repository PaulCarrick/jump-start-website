require 'rails_helper'

RSpec.describe 'Admin backup and restore', type: :request do
  let(:work) { Pathname.new(Dir.mktmpdir('site-backup')) }

  before { allow(SiteBackup).to receive(:directory).and_return(work) }
  after { FileUtils.rm_rf(work) }

  it 'is for administrators only' do
    sign_in create(:user, access: 'regular')
    get admin_backup_path
    expect(response).to redirect_to(root_path)
    post admin_backup_start_path, params: { images: true }, as: :json
    expect(response.status).to eq(302).or eq(403)
    expect(SiteBackup.status['state']).to eq('idle')
  end

  it 'shows the page, the databases and the restore form to an administrator' do
    sign_in create(:user, access: 'admin')
    get admin_backup_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Backup and restore', SiteBackup.main_database, 'Type <strong>RESTORE</strong>')
  end

  it 'sends a finished backup whole or in pieces' do
    sign_in create(:user, access: 'admin')
    FileUtils.mkdir_p(work.join('files'))
    work.join('files', 'rails_images_11-12-2026.tar.gz').binwrite('0123456789')

    get admin_backup_download_path(name: 'rails_images_11-12-2026.tar.gz')
    expect(response.body).to eq('0123456789')
    expect(response.headers['Cache-Control']).to include('no-transform')

    get admin_backup_download_path(name: 'rails_images_11-12-2026.tar.gz', offset: 4, length: 3)
    expect(response.body).to eq('456')
    expect(response.headers['X-File-Size']).to eq('10')

    get admin_backup_download_path(name: 'rails_images_11-12-2026.tar.gz', offset: 0, length: SiteBackup::DOWNLOAD_PIECE_BYTES + 1)
    expect(response).to have_http_status(:range_not_satisfiable)
  end

  it 'refuses a file that is not a backup, a restore without RESTORE, and an unknown download' do
    sign_in create(:user, access: 'admin')
    post admin_backup_upload_path(name: 'evil.sh', offset: 0, last: true), params: 'x',
         headers: { 'Content-Type' => 'application/octet-stream' }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body['error']).to match(/not a backup file/)

    post admin_backup_restore_path, params: { confirm: 'yes' }, as: :json
    expect(response.parsed_body['error']).to match(/RESTORE/)

    get admin_backup_download_path(name: 'secrets.dump')
    expect(response).to have_http_status(:not_found)
  end
end
