require 'rails_helper'

RSpec.describe "Contact Form", type: :system do
  let!(:site_setup) { SiteSetup.find_by(configuration_name: 'default') }

  before do
    if ENV["DEBUG"].present? || ENV["RSPEC_DEBUG"].present?
      driven_by(:selenium_chrome)
    else
      driven_by(:selenium_chrome_headless)
    end
  end

  describe "Contact Form Page" do
    before { visit new_contact_path }

    it "displays the correct title" do
      expect(page).to have_title("#{site_setup.site_name} - Contact")
    end

    it "displays the contact form" do
      expect(page).to have_field("contact[name]")
      expect(page).to have_field("contact[email]")
      expect(page).to have_field("Phone Number (optional)")
      expect(page).to have_css("trix-editor#contact_message")
      expect(page).to have_button("Send Message")
    end
  end

  describe "Submitting the Contact Form" do
    before { visit new_contact_path }

    context "when all required fields are filled correctly" do
      it "submits the form successfully and displays a success message" do
        fill_in "Full Name*", with: "John Doe"
        fill_in "contact[email]", with: "john.doe@example.com"
        fill_in "Phone Number (optional)", with: "+1 (555) 555-5555"
        fill_in_trix_editor("contact_message", with: "I am interested in your services.")
        click_button "Send Message"
        sleep 5
        expect(page).to have_content("The contact information was successfully sent.")
        expect(page).to have_title("#{site_setup.site_name} - Contact")
      end
    end
  end
end
