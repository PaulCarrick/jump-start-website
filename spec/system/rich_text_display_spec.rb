require 'rails_helper'

RSpec.describe 'Rich text cell display', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    page.driver.browser.manage.window.resize_to(1400, 1000)
  end

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
  it 'does not count source newlines after br tags as extra visible lines' do
    record = create(:page)
    section = create(:section, page: record, content_type: record.section)
    create(:cell, section: section, image: nil, link: nil,
           content: "<p style=\"line-height: 20px;\"><span class=\"spacing-first\">First line</span><br>\n  <span class=\"spacing-second\">Second line</span></p>")
    visit page_path(record.name)
    expect(page).to have_css('.spacing-second', text: 'Second line')
    distance = page.evaluate_script("document.querySelector('.spacing-second').getBoundingClientRect().top - document.querySelector('.spacing-first').getBoundingClientRect().top")
    expect(distance).to be_within(1).of(20)
  end

  it 'reduces large Quill sizes on phones while keeping ordinary text readable' do
    record = create(:page)
    section = create(:section, page: record, content_type: record.section)
    create(:cell, section: section, image: nil, link: nil,
           content: '<p><span class="ql-size-small">Small</span> <span class="ordinary-text">Normal</span> <span class="ql-size-large">Large</span> <span class="ql-size-huge">Huge</span></p>')
    visit page_path(record.name)
    expect(page).to have_css('.ql-size-huge', text: 'Huge')
    desktop_huge = page.evaluate_script("parseFloat(getComputedStyle(document.querySelector('.rich-text-content .ql-size-huge')).fontSize)")
    page.driver.browser.manage.window.resize_to(390, 844)
    sizes = page.evaluate_script("['.ql-size-small', '.ordinary-text', '.ql-size-large', '.ql-size-huge'].map(s => parseFloat(getComputedStyle(document.querySelector('.rich-text-content ' + s)).fontSize))")
    expect(sizes).to eq([ 14, 16, 20, 28 ])
    expect(sizes.last).to be < desktop_huge
  end

  it 'stacks saved narrow columns on phones so headings do not break mid-word' do
    record = create(:page)
    section = create(:section, page: record, content_type: record.section, section_name: 'mobile-heading')
    create(:cell, section: section, section_name: section.section_name, cell_order: 1, image: nil, link: nil,
           width: '33%', formatting: { classes: 'col-lg-4' }, content: '<h2>Music and Theater</h2>')
    create(:cell, section: section, section_name: section.section_name, cell_order: 2, image: nil, link: nil,
           width: '67%', formatting: { classes: 'col-lg-8' }, content: '<p>Musically, Paul plays guitar and keyboards.</p>')
    visit page_path(record.name)
    expect(page).to have_css('#mobile-heading h2', text: 'Music and Theater')
    geometry = "Array.from(document.querySelector('#mobile-heading').children).map(c => { const r = c.getBoundingClientRect(); return {top: r.top, width: r.width, bottom: r.bottom}; })"
    desktop = page.evaluate_script(geometry)
    expect((desktop[0]['top'] - desktop[1]['top']).abs).to be < 1
    expect(desktop[1]['width']).to be > desktop[0]['width'] * 1.9
    page.driver.browser.manage.window.resize_to(390, 844)
    mobile = page.evaluate_script(geometry)
    expect((mobile[0]['width'] - mobile[1]['width']).abs).to be < 1
    expect(mobile[1]['top']).to be >= mobile[0]['bottom'] - 1
    heading = page.evaluate_script("(() => { const h = document.querySelector('#mobile-heading h2'); return {height:h.getBoundingClientRect().height, lineHeight:parseFloat(getComputedStyle(h).lineHeight)}; })()")
    expect(heading['height']).to be < heading['lineHeight'] * 1.5
    # Desktop ratios must survive resizing back from the mobile layout.
    page.driver.browser.manage.window.resize_to(1400, 1000)
    expect(page.evaluate_script(geometry)[0]['width']).to be_within(1).of(desktop[0]['width'])
  end
end
