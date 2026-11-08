# Menu and footer links are shown to every visitor, so refuse addresses that
# would run code when clicked (javascript:, data:, vbscript: ...). Links to
# pages on this site have no scheme and are always allowed.
module SafeLink
  extend ActiveSupport::Concern

  SAFE_SCHEMES = %w[http https mailto tel].freeze

  included do
    validate :link_is_safe
  end

  private

  def link_is_safe
    # Browsers ignore spaces and control characters inside a scheme ("java script:").
    compact = link.to_s.gsub(/[[:space:][:cntrl:]]/, "")
    scheme  = compact[/\A([a-z][a-z0-9+.\-]*):/i, 1]

    return if scheme.nil? || SAFE_SCHEMES.include?(scheme.downcase)

    errors.add(:link, "must be a page on this site or an http, https, mailto or tel address")
  end
end
