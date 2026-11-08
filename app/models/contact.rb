# /app/models/contacts.rb
class Contact < ApplicationRecord
  include Enableable
  include BitemporalRecord
  before_validation :clean_message

  validates :name, :message, presence: true
  validate :message_has_text
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

  private

  # The message comes from a visitor's rich-text editor.
  def clean_message
    self.message = HtmlCleaner.clean(message) if message.present?
  end

  # An empty editor still sends markup such as "<p><br></p>".
  def message_has_text
    return if message.blank?

    errors.add(:message, "can't be blank") if Nokogiri::HTML::DocumentFragment.parse(message).text.strip.empty?
  end
end
