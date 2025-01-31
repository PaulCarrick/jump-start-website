require 'rails_helper'

# This tests the React Code
RSpec.describe "Pages", type: :system do
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:text_page) { create(:page, name: "text_page", section: "text_page", title: "Text Page") }
  let!(:html_page) { create(:page, name: "html_page", section: "html_page", title: "HTML Page") }
  let!(:text_left) { create(:page, name: "text_left_page", section: "text_left", title: "Text Left Page") }
  let!(:text_right) { create(:page, name: "text_right_page", section: "text_right", title: "Text Right Page") }
  let!(:text_top) { create(:page, name: "text_top_page", section: "text_top", title: "Text Top Page") }
  let!(:text_bottom) { create(:page, name: "text_bottom_page", section: "text_bottom", title: "Text Bottom Page") }
  let!(:image_section) { create(:page, name: "image_section_page", section: "image_section", title: "Image Section Page") }
  let!(:image_group) { create(:page, name: "image_group_page", section: "image_group", title: "Image Group Page") }
  let!(:video_image) { create(:page, name: "video_image_page", section: "video_image", title: "Video Image Page") }
  let!(:text_section) { create(:section, :plain_text) }
  let!(:html_section) { create(:section, :plain_html) }
  let!(:text_left_section) { create(:section, :text_left) }
  let!(:text_right_section) { create(:section, :text_right) }
  let!(:text_top_section) { create(:section, :text_top) }
  let!(:text_bottom_section) { create(:section, :text_bottom) }
  let!(:image_section_section) { create(:section, :image_section) }
  let!(:image_group_section) { create(:section, :image_group) }
  let!(:video_image_section) { create(:section, :video_image, description: 'VideoImage:"pact_video"') }
  let!(:test_photo) { create(:image_file, :test_photo) }
  let!(:test_photo_2) { create(:image_file, :test_photo_2) }
  let!(:test_photo_3) { create(:image_file, :test_photo_3) }
  let!(:virginia) { create(:image_file, :virginia) }
  let!(:backyard) { create(:image_file, :backyard) }
  let!(:pact_video) { create(:image_file, :pact_video) }

  before do
    ENV['IMAGE_HACK'] = true.to_s

    if ENV["DEBUG"].present? || ENV["RSPEC_DEBUG"].present?
      driven_by(:selenium_chrome)
    else
      driven_by(:selenium_chrome_headless)
    end
  end

  describe "Renders a text Page" do
    before { visit page_path("text_page") }

    it "displays the text page correctly" do
      expect(page).to have_content(text_section.description)
    end
  end

  describe "Renders a html Page" do
    before { visit page_path("html_page") }

    it "displays the html page correctly" do
      rendered_html            = page.evaluate_script('document.querySelector(".col-12").innerHTML').strip
      expected_html            = "<div><div>#{html_section.description.strip}</div></div>"
      rendered_html_normalized = Nokogiri::HTML.fragment(rendered_html).to_html
      expected_html_normalized = Nokogiri::HTML.fragment(expected_html).to_html

      expect(rendered_html_normalized).to eq(expected_html_normalized)
    end
  end

  describe "Renders a text left Page" do
    before { visit page_path("text_left_page") }

    it "displays the text left page correctly" do
      rendered_html            = page.evaluate_script('document.querySelector(".col-8").innerHTML').strip
      expected_html            = "<div>#{text_left_section.description.strip}</div>"
      rendered_html_normalized = Nokogiri::HTML.fragment(rendered_html).to_html
      expected_html_normalized = Nokogiri::HTML.fragment(expected_html).to_html
      expect(rendered_html_normalized).to eq(expected_html_normalized)
      expect(page).to have_css('img.img-fluid')
    end
  end

  describe "Renders a text right Page" do
    before { visit page_path("text_right_page") }

    it "displays the text right page correctly" do
      rendered_html            = page.evaluate_script('document.querySelector(".col-8").innerHTML').strip
      expected_html            = "<div>#{text_right_section.description.strip}</div>"
      rendered_html_normalized = Nokogiri::HTML.fragment(rendered_html).to_html
      expected_html_normalized = Nokogiri::HTML.fragment(expected_html).to_html
      expect(rendered_html_normalized).to eq(expected_html_normalized)
      expect(page).to have_css('img.img-fluid')
    end
  end

  describe "Renders a text top Page" do
    before { visit page_path("text_top_page") }

    it "displays the text top page correctly" do
      first_row = all('.row').first

      within(first_row) do
        rendered_html            = page.evaluate_script('document.querySelector(".col-12").innerHTML').strip
        expected_html            = "<div><div>#{text_top_section.description.strip}</div></div>"
        rendered_html_normalized = Nokogiri::HTML.fragment(rendered_html).to_html
        expected_html_normalized = Nokogiri::HTML.fragment(expected_html).to_html
        expect(rendered_html_normalized).to eq(expected_html_normalized)
      end

      expect(page).to have_css('img.img-fluid')
    end
  end

  describe "Renders a text bottom Page" do
    before { visit page_path("text_bottom_page") }

    it "displays the text bottom page correctly" do
      expect(page).to have_css('img.img-fluid')
    end
  end

  describe "Renders a image section Page" do
    before { visit page_path("image_section_page") }

    it "displays the Image Section page correctly" do
      expect(page).to have_css('img.img-fluid')
    end
  end

  describe "Renders an image group Page" do
    before { visit page_path("image_group_page") }

    it "displays the Image Group page correctly" do
      expect(page).to have_content("Next")
    end
  end

  describe "Renders a video image Page" do
    before { visit page_path("video_image_page") }

    it "displays the Video Image page correctly" do
      expect(page).to have_content("This is an introduction to PACT")
    end
  end
end
