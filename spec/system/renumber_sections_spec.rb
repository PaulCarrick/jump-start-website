require "rails_helper"

RSpec.describe "Renumber sections from the page editor", type: :system do
  it "places the button next to Preview and renumbers without rearranging the sections" do
    driven_by(:selenium_chrome_headless)
    page.current_window.resize_to(1440, 1100)
    login_as(create(:user, access: "super"))
    record = create(:page)
    sections = [ 80, -20, 5, nil ].map do |order|
      section = create(:section, page: record, content_type: record.section, section_order: order)
      create(:cell, section: section, image: nil, link: nil, content: "<p>Section #{order || 'without a number'}</p>")
      section
    end
    expected_ids = [ sections[1], sections[2], sections[0], sections[3] ].map(&:id)
    visit edit_admin_page_path(record)
    before_ids = all('a', text: 'Edit Section', exact_text: true).map { |link| URI.parse(link[:href]).path.split('/')[-2].to_i }
    expect(before_ids).to eq(expected_ids)
    heading = find('h1', text: 'Preview', exact_text: true)
    button = find_button('Renumber Sections')
    heading_center = heading.evaluate_script('this.getBoundingClientRect().top + this.getBoundingClientRect().height / 2')
    button_center = button.evaluate_script('this.getBoundingClientRect().top + this.getBoundingClientRect().height / 2')
    expect((heading_center - button_center).abs).to be <= 1
    click_button 'Renumber Sections'
    expect(page).to have_content('Sections renumbered successfully.')
    expect(page).to have_current_path(edit_admin_page_path(record, return_url: admin_pages_path))
    after_ids = all('a', text: 'Edit Section', exact_text: true).map { |link| URI.parse(link[:href]).path.split('/')[-2].to_i }
    expect(after_ids).to eq(expected_ids)
    expect(record.ordered_sections.pluck(:section_order)).to eq([ 10, 20, 30, 40 ])
    page.execute_script("document.querySelector('button[form=\"renumber-sections-#{record.id}\"]').scrollIntoView({block:'center',behavior:'instant'});")
    page.save_screenshot(Rails.root.join('tmp/renumber-sections-preview.png'))
  end
end
