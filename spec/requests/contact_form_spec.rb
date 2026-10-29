require "rails_helper"

RSpec.describe "Public contact form", type: :request do
  let(:contact_params) { { contact: { name: "Visitor", email: "visitor@example.com", message: "Hello" } } }

  before do
    allow(Recaptcha.configuration).to receive(:site_key).and_return("test-site-key")
    allow(Recaptcha.configuration).to receive(:secret_key).and_return("test-secret-key")
    allow(Recaptcha.configuration).to receive(:skip_verify_env).and_return([])
  end

  it "renders reCAPTCHA v3 and the contact form" do
    get new_contact_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Contact Request Form", "g-recaptcha-response-data[contact]")
    expect(Nokogiri::HTML(response.body).at_css('form#contact-form trix-editor')).to be_present
  end

  it "rejects missing tokens without saving a contact or sending mail" do
    expect(ContactMailer).not_to receive(:contact_email)
    expect { post contacts_path, params: contact_params }.not_to change(Contact, :count)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("reCAPTCHA verification failed")
  end

  it "checks the contact action and score before saving and emailing" do
    expect_any_instance_of(ContactsController).to receive(:verify_recaptcha)
      .with(model: instance_of(Contact), action: "contact", minimum_score: 0.5).and_return(true)
    delivery = double("delivery", deliver_now: true)
    expect(ContactMailer).to receive(:contact_email).and_return(delivery)
    expect { post contacts_path, params: contact_params }.to change(Contact, :count).by(1)
    expect(response).to have_http_status(:redirect)
  end

  it "renders an unavailable form instead of raising when keys are missing" do
    allow(Recaptcha.configuration).to receive(:site_key).and_return(nil)
    get new_contact_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("temporarily unavailable")
    expect(Nokogiri::HTML(response.body).at_css('input[type="submit"][disabled]')).to be_present
  end
end
