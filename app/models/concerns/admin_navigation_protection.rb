# Admin navigation entries remain visible but cannot be changed by editors.
module AdminNavigationProtection
  extend ActiveSupport::Concern

  included do
    validate :preserve_admin_navigation, on: :update
  end

  def admin_navigation_read_only?
    link.to_s.start_with?('/admin') || (persisted? && attribute_in_database('link').to_s.start_with?('/admin'))
  end

  private

  def preserve_admin_navigation
    return unless PublishingContext.editing && !PublishingContext.deploying
    if attribute_in_database('link').to_s.start_with?('/admin')
      errors.add(:base, 'Items linking to /admin are read-only.')
    end
  end
end
