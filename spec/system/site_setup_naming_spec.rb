require 'rails_helper'

RSpec.describe 'Site setup name suggestions', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
  end

  it 'copies default fields without persisting and derives values from a changed name' do
    original = SiteSetup.find_by!(default_setup: true)
    count = SiteSetup.count
    visit new_admin_site_setup_path
    expect(SiteSetup.count).to eq(count)
    expect(page).to have_field('site_setup[site_name]', with: original.site_name)
    expect(page).to have_field('site_setup[site_domain]', with: original.site_domain)
    expect(page).to have_unchecked_field('site_setup[default_setup]', visible: :all)
    find_field('site_setup[configuration_name]').click
    find_field('site_setup[configuration_name]').send_keys(:tab)
    expect(page).to have_field('site_setup[owner_name]', with: original.owner_name)
    expect(page).to have_field('site_setup[site_url]', with: original.site_url)
    fill_in 'site_setup[configuration_name]', with: 'jumpstart-website'
    expect(page).to have_field('site_setup[database]', with: original.database, visible: :all)
    find_field('site_setup[configuration_name]').send_keys(:tab)
    expect(page).to have_field('site_setup[site_name]', with: 'Jumpstart Website')
    expect(page).to have_field('site_setup[database]', with: 'jumpstart-website', visible: :all)
    expect(page).to have_field('site_setup[owner_name]', with: 'Jumpstart Website')
    expect(page).to have_field('site_setup[site_url]', with: "#{original.site_url}/jumpstart-website")
    expect(page).to have_content('jumpstart-website@example.com')
    fill_in 'site_setup[configuration_name]', with: 'another-site'
    find_field('site_setup[configuration_name]').send_keys(:tab)
    expect(page).to have_field('site_setup[site_url]', with: "#{original.site_url}/another-site")
    expect(SiteSetup.find(original.id).site_name).to eq(original.site_name)
    click_button 'Save Site Setup'
    expect(page).to have_current_path(admin_site_setups_path, ignore_query: true)
    created = SiteSetup.find_by!(database: 'another-site')
    expect(created).to be_draft
    expect(created.owner_name).to eq('Another Site')
    expect(SiteDatabase.count).to eq(0)
  end

  it 'replaces a previous URL suffix and leaves a managed database name unchanged' do
    setup = create(:site_setup, default_setup: false, database: 'original-site',
                   site_name: 'original-site', site_url: 'https://example.com/original-site')
    SiteDatabase.create!(name: setup.database, site_setup_id: setup.id, ownership_token: SecureRandom.uuid, bootstrapped: true)
    visit edit_admin_site_setup_path(setup)
    fill_in 'site_setup[site_name]', with: 'updated-site'
    find_field('site_setup[site_name]').send_keys(:tab)
    expect(page).to have_field('site_setup[site_url]', with: 'https://example.com/updated-site')
    expect(page).to have_field('site_setup[database]', with: 'original-site', readonly: true, visible: :all)
    expect(page).to have_field('site_setup[owner_name]', with: 'Updated Site')
  end
end
