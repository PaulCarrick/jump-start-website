module HtmlSanitizer
  extend ActiveSupport::Concern

  private

  require "nokogiri"

  def sanitize_html(html_string)
    # Parse the HTML string with Nokogiri
    doc = Nokogiri::HTML::DocumentFragment.parse(html_string)

    # Allowed tags
    allowed_tags = %w[br p a b i h1 h2 h3 h4 h5 div section button title li ul iframe video]

    # Traverse through the nodes
    doc.traverse do |node|
      if node.element?
        # If the tag is not allowed, replace it with its text content
        if !allowed_tags.include?(node.name)
          node.replace(node.content)
        else
          # Remove attributes starting with "on" (e.g., onclick, onmouseover)
          node.attributes.each do |name, _attribute|
            node.remove_attribute(name) if name.match?(/^on\w+/)
          end
        end
      end
    end

    # Return the sanitized HTML as a string
    doc.to_html
  end
end
