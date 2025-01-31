module Utilities
  require "nokogiri"
  require "htmlbeautifier"

  def self.truncate_html(html, max_length)
    # Parse the HTML
    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    truncated_html = ""
    char_count = 0

    doc.traverse do |node|
      break if char_count >= max_length

      if node.text?
        remaining_length = max_length - char_count
        truncated_content = node.content[0, remaining_length]
        truncated_html << Nokogiri::HTML::DocumentFragment.parse(truncated_content).to_html
        char_count += truncated_content.length
      elsif node.element?
        truncated_html << "<#{node.name}#{node.attributes.map { |k, v| " #{k}='#{v}'" }.join}>"
      end
    end

    truncated_doc = Nokogiri::HTML::DocumentFragment.parse(truncated_html)
    truncated_doc.to_html
  end

  def self.pretty_print_json(data, html = true)
    return unless data.present?

    # Ensure the data is a hash or array, if it's a string, parse it as JSON
    parsed_data = data.is_a?(String) ? JSON.parse(data) : data

    # Pretty print the JSON
    if html
      results = JSON.pretty_generate(parsed_data).gsub(/^(\s+)/) do |match|
        "&nbsp;&nbsp;&nbsp;&nbsp;" * (match.size / 2)
      end
      results.gsub("\n", "<br>")
    else
      JSON.pretty_generate(parsed_data).gsub(/^(\s+)/) do |match|
        "    " * (match.size / 2)
      end
    end
  end

  def self.pretty_print_html(html)
    return unless html.present?

    HtmlBeautifier.beautify(html)
  end
end
