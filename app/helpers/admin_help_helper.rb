require "rdoc"
require "rdoc/markdown"
require "rdoc/markup/to_html"

module AdminHelpHelper
  def admin_help_document
    source = Rails.root.join("docs/admin-guide.md").read
    html = RDoc::Markdown.parse(source).accept(RDoc::Markup::ToHtml.new(RDoc::Options.new))
    document = Nokogiri::HTML::DocumentFragment.parse(html)
    document.css("h1, h2, h3").each do |heading|
      heading.css("span").remove # RDoc's generated navigation uses different anchors.
      heading["id"] = heading.text.parameterize
    end
    sanitize(document.to_html, tags: %w[h1 h2 h3 p a ul ol li strong em code pre blockquote hr], attributes: %w[id href title])
  end
end
