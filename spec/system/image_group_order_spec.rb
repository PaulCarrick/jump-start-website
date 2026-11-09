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

  # The pointer moves in small steps, as a mouse does, so the movement events
  # land on the other boxes it passes over (dragging along a row once did
  # nothing because of that).
  def drag_onto(item, target, past:)
    from = item.native.rect
    to = target.native.rect
    distance = (to.x + to.width / 2 + past) - (from.x + from.width / 2)
    steps = (distance.abs / 15.0).ceil
    action = page.driver.browser.action.move_to(item.native).click_and_hold
    steps.times { action = action.move_by((distance / steps).round, 0) }
    action.release.perform
  end

  it 'moves a picture to the right along the row by dragging it' do
    drag_onto(find('.admin-slide[data-name="birds-1"]'), find('.admin-slide[data-name="birds-3"]'), past: 10)
    expect(strip_names).to eq(%w[birds-2 birds-3 birds-1])
    expect(page).to have_css('.admin-slide-order-status', text: 'Saved as a draft')
    expect(saved_order).to eq(%w[birds-2 birds-3 birds-1])
  end

  it 'moves a picture to the left along the row by dragging it' do
    drag_onto(find('.admin-slide[data-name="birds-3"]'), find('.admin-slide[data-name="birds-1"]'), past: -10)
    expect(strip_names).to eq(%w[birds-3 birds-1 birds-2])
    expect(page).to have_css('.admin-slide-order-status', text: 'Saved as a draft')
    expect(saved_order).to eq(%w[birds-3 birds-1 birds-2])
  end
end
