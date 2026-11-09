require 'rails_helper'

# A column showing a slide show (an image group) also shows its own text,
# above the slides. The text used to be dropped.
RSpec.describe 'Text in a slide-show column', type: :system do
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:page_record) { create(:page, name: 'garden', section: 'garden-content', title: 'Our Garden') }
  let!(:section) { create(:section, page: page_record, content_type: 'garden-content', section_name: 'garden-slides', image: nil, description: nil) }

  before do
    driven_by(:selenium_chrome_headless)
    create(:image_file, name: 'rose', group: 'flowers', slide_order: 1, caption: '<p>A rose</p>')
    create(:image_file, name: 'tulip', group: 'flowers', slide_order: 2, caption: '<p>A tulip</p>')
  end

  it 'shows the column text once, above the slide show' do
    create(:cell, section: section, section_name: 'garden-slides', cell_type: 'image', image: 'ImageGroup:flowers', link: nil,
                  content: '<p>Our flower garden through the year.</p>',
                  formatting: { 'classes' => 'col-lg-8', 'container_classes' => 'pt-3' })
    visit page_path('garden')
    expect(page).to have_css('.slideshow-container')
    expect(page).to have_text('Our flower garden through the year.', count: 1)
    text_top = page.evaluate_script("document.querySelector('.slideshow-text').getBoundingClientRect().top")
    slides_top = page.evaluate_script("document.querySelector('.slideshow-container img').getBoundingClientRect().top")
    expect(text_top).to be < slides_top
  end

  it 'adds nothing when the column has no text' do
    create(:cell, section: section, section_name: 'garden-slides', cell_type: 'image', image: 'ImageGroup:flowers', link: nil, content: '<p></p>',
                  formatting: { 'classes' => 'col-lg-8', 'container_classes' => 'pt-3' })
    visit page_path('garden')
    expect(page).to have_css('.slideshow-container')
    expect(page).to have_no_css('.slideshow-text')
  end
end

RSpec.describe 'Text beside a slide show in a two-part layout', type: :system do
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:page_record) { create(:page, name: 'garden', section: 'garden-content', title: 'Our Garden') }
  let!(:section) { create(:section, page: page_record, content_type: 'garden-content', section_name: 'garden-slides', image: nil, description: nil) }

  it 'keeps the text in its own column, not repeated above the slides' do
    driven_by(:selenium_chrome_headless)
    create(:image_file, name: 'rose', group: 'flowers', slide_order: 1)
    create(:cell, section: section, section_name: 'garden-slides', cell_type: 'image', image: 'ImageGroup:flowers', link: nil,
                  content: '<p>Our flower garden through the year.</p>')
    visit page_path('garden')
    expect(page).to have_css('.slideshow-container')
    expect(page).to have_text('Our flower garden through the year.', count: 1)
    expect(page).to have_no_css('.slideshow-text')
  end
end
