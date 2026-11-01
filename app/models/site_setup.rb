# /app/models/site_setup.rb
class SiteSetup < CatalogRecord
  include Enableable
  include BitemporalRecord
  validates :configuration_name, :site_name, :site_domain, :site_host, :site_url,  presence: true
  validates :contact_email_from, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }, allow_blank: true
  validates :contact_email_to, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }, allow_blank: true

  # Allow the pre-migration schema to boot for migration/rehearsal only.
  validates :database, presence: true, if: -> { has_attribute?(:database) }

  validates :database, format: { with: /\A[a-zA-Z0-9][a-zA-Z0-9_-]{0,62}\z/, message: 'must contain only letters, numbers, hyphens, or underscores (up to 63 characters)' }, if: -> { has_attribute?(:database) }
  validates :database, uniqueness: { conditions: -> { working_or_live } }, if: -> { has_attribute?(:database) }

  before_validation :derive_routing_fields
  validate :unique_routing_destination
  validate :only_one_default_allowed

  private

  def derive_routing_fields
    return unless has_attribute?(:routing_host)
    self.routing_host, self.routing_path = SiteUrl.parts(site_url)
  rescue SiteUrl::Invalid => error
    errors.add(:site_url, error.message)
  end

  def unique_routing_destination
    return unless has_attribute?(:routing_host) && routing_host.present? && enabled?
    if SiteSetup.where(routing_host: routing_host, routing_path: routing_path, enabled: true).where.not(id: id).exists?
      errors.add(:site_url, 'already maps to another enabled site setup')
    end
  end

  def only_one_default_allowed
    if self.default_setup && SiteSetup.where(default_setup: true).where.not(id: self.id).exists?
      errors.add(:default, 'There can only be one default site setup.')
    end
  end
end
