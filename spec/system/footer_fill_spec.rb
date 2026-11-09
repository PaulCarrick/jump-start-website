require 'rails_helper'

# On a short page the footer's colour reaches the bottom of the window.
RSpec.describe 'The footer on a short page', type: :system do
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }

  before { driven_by(:selenium_chrome_headless) }

  def footer_bottom = page.evaluate_script("document.querySelector('footer.footer-bg').getBoundingClientRect().bottom")
  def window_height = page.evaluate_script('window.innerHeight')

  %w[top left].each do |position|
    it "reaches the bottom of the window with the menu at the #{position}" do
      SiteSetup.unscoped.where(id: site_setup.id).update_all(menu_position: position)
      page.driver.browser.manage.window.resize_to(1400, 1400)
      visit new_search_path
      expect(page).to have_css('footer.footer-bg')
      expect(footer_bottom).to be_within(2).of(window_height)
    end
  end
end
