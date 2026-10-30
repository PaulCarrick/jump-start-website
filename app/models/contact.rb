# /app/models/contacts.rb
class Contact < ActiveRecord::Base
  include Enableable
  include BitemporalRecord
  validates :name, :message, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :unique_combination

  scope :by_name_email_phone_message, ->(name, email, phone, message) {
    where(name: name, email: email, phone: phone, message: message)
  }

  def unique_combination
    contacts = Contact.by_name_email_phone_message(self.name, self.email, self.phone, self.message)
    contacts = contacts.where.not(id: id) if persisted?
    return unless contacts.exists?

    errors.add(:base, "The contact information must be unique. You have already submitted this information. Please at least change the description.")
  end
end
