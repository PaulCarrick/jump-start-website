# Admin navigation entries remain visible and can be moved, but editors cannot otherwise change them.
module AdminNavigationProtection
  extend ActiveSupport::Concern

  # Moving an entry within its menu changes only these.
  POSITION_FIELDS = %w[menu_order footer_order parent_id].freeze

  included do
    validate :preserve_admin_navigation, on: :update
  end

  def admin_navigation_read_only?
    link.to_s.start_with?('/admin') || (persisted? && attribute_in_database('link').to_s.start_with?('/admin'))
  end

  private

  def preserve_admin_navigation
    return unless PublishingContext.editing && !PublishingContext.deploying
    # A form sends empty fields back as "" where the record had nil; that is
    # not a change, so moving an item through its form is still allowed.
    changed_fields = changes.reject { |_field, (before, after)| before.blank? && after.blank? }.keys
    return if (changed_fields - POSITION_FIELDS).empty?

    if attribute_in_database('link').to_s.start_with?('/admin')
      errors.add(:base, 'Items linking to /admin are read-only.')
    end
  end
end
