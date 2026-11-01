require 'rails_helper'

RSpec.describe SiteUrl do
  it 'normalizes host case, trailing dots, and a trailing path slash' do
    expect(described_class.parts('https://EXAMPLE.com./jumpstart-server/')).to eq(['example.com', '/jumpstart-server'])
  end

  it 'rejects unsafe or ambiguous URL forms' do
    ['//example.com/a', 'https://user:password@example.com/a', 'https://example.com/a?db=other', 'https://example.com/a#fragment', 'https://example.com/a/../b', 'https://example.com/a%2fb'].each do |url|
      expect { described_class.parts(url) }.to raise_error(SiteUrl::Invalid)
    end
  end

  it 'rejects duplicate active routes but allows different prefixes on one host' do
    create(:site_setup, site_url: 'https://example.com/site')
    duplicate = build(:site_setup, default_setup: false, database: 'another-database', site_url: 'http://EXAMPLE.com/site/')
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:site_url]).to be_present
    duplicate.site_url = 'https://example.com/other-site'
    expect(duplicate).to be_valid
  end

  it 'has URL and normalized lookup indexes' do
    indexes = CatalogRecord.connection.indexes(:site_setups)
    expect(indexes.map(&:columns)).to include(['site_url'], ['routing_host', 'routing_path'])
  end
end
