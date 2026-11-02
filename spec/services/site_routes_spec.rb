require 'rails_helper'

RSpec.describe SiteRoutes do
  let!(:default) { create(:site_setup, site_url: 'https://paul-carrick.com') }
  let!(:tenant) { create(:site_setup, default_setup: false, database: 'jump-start', site_url: 'https://paul-carrick.com/jumpstart-server') }

  it 'substitutes loopback origins at runtime while preserving paths and stored URLs' do
    %w[localhost 127.0.0.1 ::1].each do |host|
      expect(described_class.resolve(host, '/').setup_id).to eq(default.id)
      route = described_class.resolve(host, '/jumpstart-server/admin/pages')
      expect([ route.setup_id, route.database, route.path ]).to eq([ tenant.id, 'jump-start', '/jumpstart-server' ])
      expect(described_class.resolve(host, '/jumpstart-server-other').setup_id).to eq(default.id)
    end
    expect(tenant.reload.site_url).to eq('https://paul-carrick.com/jumpstart-server')
  end

  it 'does not merge unrelated production hosts into localhost' do
    create(:site_setup, default_setup: false, database: 'other-site', site_url: 'https://other.example/other')
    expect(described_class.resolve('localhost', '/other').setup_id).to eq(default.id)
  end

  it 'does not enable local origin substitution in production' do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
    expect(described_class.resolve('localhost', '/jumpstart-server')).to be_nil
    expect(described_class.resolve('paul-carrick.com', '/jumpstart-server').setup_id).to eq(tenant.id)
  end

  it 'fails closed when a stored local URL conflicts with a substituted URL' do
    create(:site_setup, default_setup: false, database: 'local-conflict', site_url: 'http://localhost:3100/jumpstart-server')
    expect { described_class.resolve('localhost', '/jumpstart-server') }.to raise_error(SiteRoutes::Unavailable)
  end
end
