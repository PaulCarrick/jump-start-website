require 'rails_helper'

RSpec.describe 'The site menu in each position', type: :system do
  let!(:setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:page_record) { create(:page, name: 'garden', section: 'garden-content', title: 'Garden') }

  before do
    driven_by(:selenium_chrome_headless)
    SiteSetup.unscoped.where(id: setup.id).update_all(menu_position: position)
  end

  def header_box = page.evaluate_script("(() => { const r = document.querySelector('header:has(.site-menu)').getBoundingClientRect(); return { left: r.left, right: r.right, top: r.top, bottom: r.bottom, width: r.width }; })()")
  def window_size = page.evaluate_script('({ width: innerWidth, height: innerHeight })')

  def wide
    page.driver.browser.manage.window.resize_to(1400, 900)
  end

  context 'on the left' do
    let(:position) { 'left' }

    it 'is a sidebar down the left on a wide screen, and the top bar on a phone' do
      wide
      visit page_path('garden')
      box = header_box
      expect(box['left']).to eq(0)
      expect(box['width']).to be_within(2).of(250)
      expect(box['bottom']).to be_within(2).of(window_size['height'])
      page.driver.browser.manage.window.resize_to(400, 800)
      visit page_path('garden')
      expect(header_box['width']).to be > 300
      expect(page).to have_css('.navbar-toggler', visible: true)
    end
  end

  context 'on the right' do
    let(:position) { 'right' }

    it 'is a sidebar down the right' do
      wide
      visit page_path('garden')
      box = header_box
      expect(box['right']).to be_within(2).of(window_size['width'])
      expect(box['width']).to be_within(2).of(250)
    end
  end

  context 'at the bottom' do
    let(:position) { 'bottom' }

    it 'is a bar along the bottom of the window, with room kept for it under the page' do
      wide
      visit page_path('garden')
      box = header_box
      expect(box['bottom']).to be_within(2).of(window_size['height'])
      expect(box['top']).to be > 400
      padding = page.evaluate_script("parseFloat(getComputedStyle(document.body).paddingBottom)")
      expect(padding).to be_within(4).of(box['bottom'] - box['top'])
    end
  end

  context 'at the top' do
    let(:position) { 'top' }

    it 'stays the normal header' do
      wide
      visit page_path('garden')
      expect(header_box['top']).to eq(0)
      expect(header_box['width']).to be_within(2).of(window_size['width'])
    end
  end
end
