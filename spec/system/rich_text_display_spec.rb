require 'rails_helper'

RSpec.describe 'Rich text cell display', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  it 'renders saved huge text larger than ordinary text on the public page' do
    record = create(:page)
    section = create(:section, page: record, content_type: record.section)
    create(:cell, section: section, image: nil, link: nil,
           content: '<p><span class="ql-size-huge">Huge heading</span></p><p><span class="ordinary-text">Ordinary text</span></p>')
    visit page_path(record.name)
    expect(page).to have_css('.rich-text-content .ql-size-huge', text: 'Huge heading')
    huge_size = page.evaluate_script("parseFloat(getComputedStyle(document.querySelector('.rich-text-content .ql-size-huge')).fontSize)")
    ordinary_size = page.evaluate_script("parseFloat(getComputedStyle(document.querySelector('.rich-text-content .ordinary-text')).fontSize)")
    expect(huge_size).to be > ordinary_size * 2
  end
end
