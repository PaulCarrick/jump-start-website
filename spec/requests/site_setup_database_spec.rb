require 'rails_helper'

RSpec.describe 'Site setup database field', type: :request do
  it 'shows a required database field and saves changes through the normal draft workflow' do
    setup = create(:site_setup)
    admin = create(:user, access: 'super')
    sign_in admin
    expect(setup.database).to eq('paul-carrick')
    get edit_admin_site_setup_path(setup)
    field = Nokogiri::HTML(response.body).at_css('input[name="site_setup[database]"]')
    expect(field['required']).to be_present
    expect(field['value']).to eq('paul-carrick')
    patch admin_site_setup_path(setup), params: { site_setup: { database: 'another-site' } }
    expect(SiteSetup.find(setup.id).database).to eq('another-site')
    PublishingContext.live = true
    expect(SiteSetup.find(setup.id).database).to eq('paul-carrick')
    Publishing.deploy!(actor: admin, summary: 'Update stored database setting')
    expect(SiteSetup.find(setup.id).database).to eq('another-site')
    expect(SiteSetup.history.where(id: setup.id, database: 'another-site')).to exist
  end

  it 'rejects blank values without creating a pending change' do
    setup = create(:site_setup)
    PublishingContext.editing = true
    expect(setup.update(database: ' ')).to be(false)
    expect(setup.errors[:database]).to include("can't be blank")
    expect(SiteSetup.pending_versions.where(id: setup.id)).not_to exist
  end
end
