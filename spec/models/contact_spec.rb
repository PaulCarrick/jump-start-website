require 'rails_helper'

RSpec.describe Contact, type: :model do
  include_context "debug setup"

  describe "validations" do
    it "validates presence of name" do
      contact = Contact.new(message: "This is a message", email: "test@example.com")
      expect(contact.valid?).to be false
      expect(contact.errors[:name]).to include("can't be blank")
    end

    it "validates presence of message" do
      contact = Contact.new(name: "Test Name", email: "test@example.com")
      expect(contact.valid?).to be false
      expect(contact.errors[:message]).to include("can't be blank")
    end

    it "validates email format" do
      contact = Contact.new(name: "Test Name", message: "This is a message", email: "invalid_email")
      expect(contact.valid?).to be false
      expect(contact.errors[:email]).to include("is invalid")
    end

    it "allows valid email format" do
      contact = Contact.new(name: "Test Name", message: "This is a message", email: "test@example.com")
      expect(contact.valid?).to be true
    end
  end

  describe "unique_combination validation" do
    before do
      Contact.create!(
        name: "Test Name",
        email: "test@example.com",
        phone: "1234567890",
        message: "This is a message"
      )
    end

    it "adds an error if the combination is not unique" do
      duplicate_contact = Contact.new(
        name: "Test Name",
        email: "test@example.com",
        phone: "1234567890",
        message: "This is a message"
      )

      expect(duplicate_contact.valid?).to be false
      expect(duplicate_contact.errors[:base]).to include("The contact information must be unique. You have already submitted this information. Please at least change the description.")
    end

    it "does not add an error if the combination is unique" do
      unique_contact = Contact.new(
        name: "New Name",
        email: "new@example.com",
        phone: "0987654321",
        message: "This is a different message"
      )

      expect(unique_contact.valid?).to be true
    end
  end

  describe "scopes" do
    describe ".by_name_email_phone_message" do
      let!(:contact) do
        Contact.create!(
          name: "Test Name",
          email: "test@example.com",
          phone: "1234567890",
          message: "This is a message"
        )
      end

      it "returns the correct contact when given matching attributes" do
        result = Contact.by_name_email_phone_message("Test Name", "test@example.com", "1234567890", "This is a message")
        expect(result).to include(contact)
      end

      it "does not return a contact when attributes do not match" do
        result = Contact.by_name_email_phone_message("Nonexistent Name", "noemail@example.com", "1112223333", "Different message")
        expect(result).to be_empty
      end
    end
  end
end
