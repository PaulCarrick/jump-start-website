# /app/models/site_setup.rb
class SiteSetup < ActiveRecord::Base
  validates :configuration_name, :site_name, :site_domain, :site_host, :site_url,  presence: true
  validates :contact_email_from, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }, allow_blank: true
  validates :contact_email_to, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }, allow_blank: true

  validate :only_one_default_allowed

  private

  def only_one_default_allowed
    if self.default_setup && SiteSetup.where(default_setup: true).where.not(id: self.id).exists?
      errors.add(:default, 'There can only be one default site setup.')
    end
  end
end
