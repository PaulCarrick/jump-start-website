require 'rails_helper'

RSpec.describe 'Dragging the pictures of a group into order', type: :system do
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:first) { create(:image_file, name: 'birds-1', group: 'birds', slide_order: 1) }
  let!(:second) { create(:image_file, name: 'birds-2', group: 'birds', slide_order: 2) }
  let!(:third) { create(:image_file, name: 'birds-3', group: 'birds', slide_order: 3) }

  before do
    driven_by(:selenium_chrome_headless)
    login_as(create(:user, access: 'super'))
    visit admin_image_files_path('q[group_eq]' => 'birds')
    expect(page).to have_css('.admin-slide', count: 3)
  end

  def strip_names = all('.admin-slide').map { |item| item['data-name'] }
  def saved_order = [ first, second, third ].sort_by { |file| ImageFile.find(file.id).slide_order }.map(&:name)

  it 'moves a picture with the arrow keys and saves the order' do
    find('.admin-slide[data-name="birds-1"]').send_keys(:arrow_right, :arrow_right)
    expect(strip_names).to eq(%w[birds-2 birds-3 birds-1])
    expect(page).to have_css('.admin-slide-order-status', text: 'Saved as a draft')
    expect(saved_order).to eq(%w[birds-2 birds-3 birds-1])
    expect(page).to have_css('.admin-publish-button', text: '3')
    expect(page).to have_css('.admin-slide[data-name="birds-1"] .admin-slide-number', text: '3')
  end

  it 'moves a picture by dragging it' do
    source = find('.admin-slide[data-name="birds-3"]')
    target = find('.admin-slide[data-name="birds-1"]')
    page.driver.browser.action
        .move_to(source.native).click_and_hold
        .move_by(-10, 0)
        .move_to(target.native, -(target.native.rect.width / 2 - 4), 0)
        .release.perform
    expect(strip_names).to eq(%w[birds-3 birds-1 birds-2])
    expect(page).to have_css('.admin-slide-order-status', text: 'Saved as a draft')
    expect(saved_order).to eq(%w[birds-3 birds-1 birds-2])
  end
end
