require 'uri'

class SiteUrl
  class Invalid < StandardError; end

  def self.parts(value)
    uri = URI.parse(value.to_s.strip)
    unless uri.is_a?(URI::HTTP) && uri.hostname.present? && uri.userinfo.nil? && uri.query.nil? && uri.fragment.nil?
      raise Invalid, 'must be an absolute http(s) URL without credentials, a query, or a fragment'
    end
    host = uri.hostname.downcase.delete_suffix('.')
    path = uri.path.to_s.delete_suffix('/')
    unless path.match?(%r{\A(?:/[A-Za-z0-9._~-]+)*\z}) && path.split('/').none? { |part| %w[. ..].include?(part) }
      raise Invalid, 'must use a simple path without encoded separators or dot segments'
    end
    [ host, path ]
  rescue URI::InvalidURIError
    raise Invalid, 'must be a valid absolute http(s) URL'
  end
end
