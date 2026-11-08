# Cleans HTML written by site visitors (blog comments, contact messages) before
# it is stored or emailed. Keeps the formatting the editors produce (Quill and
# Trix) and removes scripts, event handlers, images, frames, styles and
# javascript: links.
module HtmlCleaner
  ALLOWED_TAGS = %w[p div br strong b em i u s del a ul ol li blockquote pre code h1 h2 h3 span sub sup].freeze
  ALLOWED_ATTRIBUTES = %w[href class].freeze

  def self.clean(html)
    Rails::HTML5::SafeListSanitizer.new.sanitize(html.to_s, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
  end
end
