require 'rails_helper'

# The rich-text editor saves quote marks in text as &quot;, so a column's
# VideoImage:"name" tag can reach the page as VideoImage:&quot;name&quot;.
RSpec.describe 'Video tags in a column', type: :system do
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }
  let!(:page_record) { create(:page, name: 'wedding', section: 'wedding-content', title: 'Wedding') }
  let!(:section) { create(:section, page: page_record, content_type: 'wedding-content', section_name: 'wedding-text') }
  let!(:video) { create(:image_file, name: 'joy-ryan-wedding', caption: 'Joy and Ryan’s wedding', mime_type: 'video/mp4') }

  before { driven_by(:selenium_chrome_headless) }

  [ '"', '&quot;' ].each do |quote|
    it "turns VideoImage:#{quote}name#{quote} into a link to the video" do
      create(:cell, section: section, section_name: 'wedding-text', image: nil, link: nil,
                    content: "<p>This is a video of their wedding: VideoImage:#{quote}joy-ryan-wedding#{quote}</p>")
      visit page_path('wedding')
      expect(page).to have_link('Joy and Ryan’s wedding')
      expect(page).to have_no_content('VideoImage')
    end
  end
end
