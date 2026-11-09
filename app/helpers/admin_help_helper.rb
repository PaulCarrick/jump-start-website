require "rdoc"
require "rdoc/markdown"
require "rdoc/markup/to_html"

module AdminHelpHelper
  # Screenshots are written in the guides as ![Caption](../public/admin-help/name.webp),
  # so they also show when the Markdown is read on GitHub; on the site they are
  # served from /admin-help/.
  SCREENSHOT_PREFIX = "../public/".freeze
  SCREENSHOT_PATTERN = /!\[([^\]]*)\]\(([^)\s]+)\)/
  SCREENSHOT_TOKEN = /HELPSHOT(\d+)END/

  def admin_help_document(tutorial: false)
    source = Rails.root.join(tutorial ? "docs/new-site-tutorial.md" : "docs/admin-guide.md").read
    # RDoc keeps only the first word of an image's caption, so pictures are
    # swapped for a placeholder and drawn after the Markdown is converted.
    screenshots = []
    source = source.gsub(SCREENSHOT_PATTERN) do
      screenshots << { caption: Regexp.last_match(1), source: Regexp.last_match(2) }
      "HELPSHOT#{screenshots.size - 1}END"
    end
    html = RDoc::Markdown.parse(source).accept(RDoc::Markup::ToHtml.new(RDoc::Options.new))
    document = Nokogiri::HTML::DocumentFragment.parse(html)
    document.css("h1, h2, h3").each do |heading|
      heading.css("span").remove # RDoc's generated navigation uses different anchors.
      heading["id"] = heading.text.parameterize
    end
    document.xpath(".//text()[contains(., 'HELPSHOT')]").each do |text|
      index = text.text[SCREENSHOT_TOKEN, 1]
      screenshot = index && screenshots[index.to_i]
      next unless screenshot

      figure = admin_help_figure(document, screenshot)
      holder = text.parent
      if holder&.name == "p" && holder.text.strip == text.text.strip
        holder.replace(figure)
      else
        text.replace(figure)
      end
    end
    sanitize(document.to_html,
             tags: %w[h1 h2 h3 p a ul ol li strong em code pre blockquote hr figure figcaption img],
             attributes: %w[id href title src alt loading class target rel width height])
  end

  private

  # A captioned picture that opens full size in a new tab.
  def admin_help_figure(document, screenshot)
    source = screenshot[:source]
    source = "/#{source.delete_prefix(SCREENSHOT_PREFIX)}" if source.start_with?(SCREENSHOT_PREFIX)
    figure = Nokogiri::XML::Node.new("figure", document.document)
    figure["class"] = "admin-help-shot"
    link = Nokogiri::XML::Node.new("a", document.document)
    link["href"] = source
    link["target"] = "_blank"
    link["rel"] = "noopener"
    link["title"] = "Open full size"
    image = Nokogiri::XML::Node.new("img", document.document)
    image["src"] = source
    image["alt"] = screenshot[:caption]
    image["loading"] = "lazy"
    image["width"] = "1200"
    image["height"] = "750"
    link.add_child(image)
    figure.add_child(link)
    if screenshot[:caption].present?
      caption = Nokogiri::XML::Node.new("figcaption", document.document)
      caption.content = screenshot[:caption]
      figure.add_child(caption)
    end
    figure
  end
end
