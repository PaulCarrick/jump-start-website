# /app/models/contacts.rb
class Contact < ActiveRecord::Base
  validates :name, :message, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :unique_combination

  scope :by_name_email_phone_message, ->(name, email, phone, message) {
    where(name: name, email: email, phone: phone, message: message)
  }

  def unique_combination
    result = false
    contacts = Contact.by_name_email_phone_message(self.name, self.email, self.phone, self.message)

    if contacts.any?
      error_message = "The contact information must be unique. You have already submitted this information. Please at least change the description."

      if self.submit_information.present?
        if self.submit_information === error_message
          errors.add(:base, self.submit_information)
        end
      else
        self.submit_information = error_message
        self.save

        errors.add(:base, self.submit_information)
      end
    else
      result = true
    end

    result
  end
end
