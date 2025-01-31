require 'rails_helper'

RSpec.describe ContactsController, type: :controller do
  include_context "debug setup"

  let!(:site_setup) { SiteSetup.find_by(default_setup: true) || create(:site_setup) }

  let(:valid_params) do
    {
      contact: {
        name:    "John Doe",
        email:   "john.doe@example.com",
        phone:   "123-456-7890",
        message: "Hello, this is a test message."
      }
    }
  end

  let(:invalid_params) do
    {
      contact: {
        name:    "",
        email:   "invalid-email",
        phone:   "",
        message: ""
      }
    }
  end

  describe "GET #new" do
    it "initializes a new contact" do
      get :new
      expect(assigns(:contact)).to be_a_new(Contact)
    end

    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new contact" do
        expect {
          post :create, params: valid_params
        }.to change(Contact, :count).by(1)
      end

      it "sends a contact email" do
        response = ContactMailer.contact_email("John Doe",
                                               "john.doe@example.com",
                                               "123-456-7890",
                                               "Hello, this is a test message.",
                                               site_setup).deliver_now
        post :create, params: valid_params
      end

      it "sets a success flash message" do
        post :create, params: valid_params
        expect(flash[:info]).to include("information was successfully sent.")
      end

      it "redirects to the contact show page" do
        post :create, params: valid_params
        contact = assigns(:contact)
        expect(response).to redirect_to(contact_path(contact))
      end
    end

    context "with duplicate submission" do
      before do
        create(:contact, valid_params[:contact])
      end

      it "does not create a new contact" do
        expect {
          post :create, params: valid_params
        }.not_to change(Contact, :count)
      end

      it "sets an error flash message" do
        post :create, params: valid_params
        expect(flash[:error]).to include("You have already submitted this information")
      end
    end

    context "when an unexpected exception occurs" do
      before do
        allow(Contact).to receive(:create!).and_raise(StandardError, "Unexpected error")
      end

      it "sets a generic error flash message" do
        post :create, params: valid_params
        expect(flash[:error]).to eq("Unexpected error")
      end
    end
  end

  describe "GET #show" do
    let(:contact) { create(:contact, submit_information: "Contact submitted successfully.") }

    it "assigns the requested contact" do
      get :show, params: { id: contact.id }
      expect(assigns(:contact)).to eq(contact)
    end

    it "assigns the contact's submit information" do
      get :show, params: { id: contact.id }
      expect(assigns(:results)).to eq("Contact submitted successfully.")
    end

    it "renders the show template" do
      get :show, params: { id: contact.id }
      expect(response).to render_template(:show)
    end
  end
end
