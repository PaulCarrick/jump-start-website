require 'rails_helper'

RSpec.describe "Pages", type: :system do
  let!(:page_record) { create(:page, name: 'render-test', title: 'Rendering test') }
  let!(:section) { create(:section, page: page_record, content_type: page_record.section) }

  before do
    if ENV["DEBUG"].present? || ENV["RSPEC_DEBUG"].present?
      driven_by(:selenium_chrome)
    else
      driven_by(:selenium_chrome_headless)
    end
  end

  def text_column(content, order: 1, width: '100%', formatting: {})
    create(:cell, section: section, content: content, image: nil, link: nil,
           cell_order: order, cell_type: 'text', width: width, formatting: formatting)
  end

  def image_column(order: 1, width: '100%')
    image = create(:image_file)
    create(:cell, section: section, content: nil, cell_type: 'image',
           image: "ImageFile:#{image.name}", link: nil, cell_order: order, width: width)
  end

  it "renders a text column on its owning page" do
    text_column('Public text column')
    visit page_path(page_record.name)
    within('#contents', match: :first) { expect(page).to have_content('Public text column') }
  end

  it "preserves saved rich text markup" do
    text_column('<p>A <strong>bold phrase</strong> and <em>italic phrase</em></p>')
    visit page_path(page_record.name)
    within('#contents', match: :first) do
      expect(page).to have_css('strong', text: 'bold phrase')
      expect(page).to have_css('em', text: 'italic phrase')
    end
  end

    end
  end

  it "renders text to the left of an image" do
    text_column('Text on the left', order: 1, width: '60%')
    image_column(order: 2, width: '40%')
    visit page_path(page_record.name)
    expect(page).to have_css('#contents img')
    expect(page).to have_content('Text on the left')
    children = find('#contents', match: :first).find(:id, section.section_name).all(':scope > div')
    expect(children.first).to have_text('Text on the left')
    expect(children.last).to have_css('img')
  end

  describe "Renders a html Page" do
    before { visit page_path("html_page") }

    it "displays the html page correctly" do
      rendered_html            = find('[data-react-class="RenderSection"] #contents > div > div', match: :first).native.attribute("innerHTML").strip
      expected_html            = html_section.description.strip
      rendered_html_normalized = Nokogiri::HTML.fragment(rendered_html).to_html
      expected_html_normalized = Nokogiri::HTML.fragment(expected_html).to_html

      expect(rendered_html_normalized).to eq(expected_html_normalized)
    end
  end

  it "renders text to the right of an image" do
    image_column(order: 1, width: '40%')
    text_column('Text on the right', order: 2, width: '60%')
    visit page_path(page_record.name)
    expect(page).to have_css('#contents img')
    children = find('#contents', match: :first).find(:id, section.section_name).all(':scope > div')
    expect(children.first).to have_css('img')
    expect(children.last).to have_text('Text on the right')
  end

  end

  it "renders text above an image when both columns occupy a full row" do
    text_column('Text above the image', order: 1)
    image_column(order: 2)
    visit page_path(page_record.name)
    expect(page).to have_css('#contents img')
    children = find('#contents', match: :first).find(:id, section.section_name).all(':scope > div')
    expect(children.first).to have_text('Text above the image')
    expect(children.last).to have_css('img')
  end

  it "renders text below an image" do
    image_column(order: 1)
    text_column('Text below the image', order: 2)
    visit page_path(page_record.name)
    expect(page).to have_css('#contents img')
    children = find('#contents', match: :first).find(:id, section.section_name).all(':scope > div')
    expect(children.first).to have_css('img')
    expect(children.last).to have_text('Text below the image')
  end

  it "loads an attached image in its section" do
    image_column
    visit page_path(page_record.name)
    image = find('#contents img')
    expect(image['src']).to include('/rails/active_storage/')
    expect(image.evaluate_script('this.complete && this.naturalWidth > 0')).to be(true)
  end

  it "renders an image group slideshow" do
    create(:image_file, group: 'render-group', slide_order: 1)
    create(:image_file, group: 'render-group', slide_order: 2)
    create(:cell, section: section, content: nil, cell_type: 'image', image: 'ImageGroup:render-group', link: nil)
    visit page_path(page_record.name)
    expect(page).to have_css('#contents img')
    expect(page).to have_content('Next')
    click_button 'Next'
    expect(page).to have_css('#contents img')
  end

  it "renders a saved video link with its caption" do
    create(:image_file, :pact_video)
    text_column('VideoImage:"pact_video"')
    visit page_path(page_record.name)
    expect(page).to have_link('This is an introduction to PACT')
  end
end
