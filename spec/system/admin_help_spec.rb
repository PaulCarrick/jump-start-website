require 'rails_helper'

RSpec.describe 'Admin Help', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  it 'opens the complete guide from the bottom of the sidebar and follows topic links' do
    login_as(create(:user, access: 'super'))
    visit admin_pages_path
    within('.admin-sidebar') do
      expect(page).to have_css('.admin-nav-footer a:last-child', text: /new site tutorial/i)
      find("a[href='/admin/help']").click
    end
    expect(page).to have_current_path(admin_help_path)
    expect(page).to have_css('h1', text: 'Admin user guide')
    expect(page).to have_css('#keyboard-shortcuts', text: 'Keyboard shortcuts')
    expect(page.evaluate_script(<<~JS)).to be(true)
      Array.from(document.querySelectorAll('.admin-help a[href^="#"]')).every(link =>
        document.getElementById(decodeURIComponent(link.hash.slice(1))))
    JS
    within('.admin-help') { click_link 'Pages', exact: true }
    expect(page).to have_current_path(%r{/admin/help\#pages\z}, url: true)
    expect(page).to have_css('#common-questions')
    page.save_screenshot(Rails.root.join('tmp/admin-help.png'))
  end

  it 'shows a captioned screenshot for the steps, each loading and opening full size' do
    login_as(create(:user, access: 'super'))
    [ admin_help_path, admin_tutorial_path ].each do |path|
      visit path
      expect(page).to have_css('.admin-help-shot img', minimum: 10)
      expect(page).to have_css('.admin-help-shot figcaption', text: /\w+ \w+/)
      expect(page).to have_no_text('HELPSHOT')
      broken = page.evaluate_async_script(<<~JS)
        const done = arguments[0];
        const images = Array.from(document.querySelectorAll('.admin-help-shot img'));
        images.forEach(image => { image.loading = 'eager'; });
        Promise.all(images.map(image => image.decode().then(() => null, () => image.getAttribute('src')))).then(done);
      JS
      expect(broken.compact).to be_empty
      expect(page).to have_css('.admin-help-shot a[target="_blank"][href^="/admin-help/"]', minimum: 10)
    end
  end

  it 'opens the step-by-step tutorial below Help' do
    login_as(create(:user, access: 'super'))
    visit admin_help_path
    within('.admin-sidebar') do
      expect(page).to have_css('a[href="/admin/help"] + a', text: /new site tutorial/i)
      click_link 'New Site Tutorial'
    end
    expect(page).to have_current_path(admin_tutorial_path)
    expect(page).to have_css('h1', text: 'Build your first Jumpstart website')
    expect(page).to have_css('h2', text: 'Path A: native installation from the repository')
    expect(page).to have_css('h2', text: 'Path B: two-container installation')
    expect(page).to have_css('h2', text: 'Edit your Site Setup')
    expect(page).to have_css('h2', text: 'Create an About page with text and images')
  end

  it 'allows a read-only user to read the guide' do
    login_as(create(:user, access: 'read_only'))
    visit admin_help_path
    expect(page).to have_css('h1', text: 'Admin user guide')
  end

  it 'redirects regular users away from admin help' do
    login_as(create(:user, access: 'regular'))
    visit admin_help_path
    expect(page).to have_no_css('.admin-help')
    expect(page).to have_current_path(%r{\A/(home)?\z})
  end
end
