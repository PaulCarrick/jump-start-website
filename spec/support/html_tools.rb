module HtmlTools
  require 'nokogiri'

  # Pretty print an HTML string
  def pretty_print_html(html)
    parsed_html = Nokogiri::HTML(html)

    puts parsed_html.to_xhtml(indent: 2) if parsed_html.present?

    puts
    puts
  end

  def show_html
    pretty_print_html(page.body)
  end

  # Get an element by ID
  def get_element_by_id(html, id)
    parsed_html = Nokogiri::HTML(html)

    if parsed_html.present?
      element = parsed_html.at_css("##{id}")

      puts element.to_xhtml(indent: 2) if element.present?
    end

    puts
    puts
  end

  # Find elements by text content
  def find_elements_by_text(html, text, exact: false)
    parsed_html = Nokogiri::HTML(html)

    if exact
      parsed_html.xpath("//*[text()='#{text}']") # Find elements with exact text match
    else
      parsed_html.xpath("//*[contains(text(), '#{text}')]") # Find elements containing the text
    end
  end

  # Get the first element by text content
  def get_element_by_contents(html, text, exact: false)
    elements = find_elements_by_text(html, text, exact: exact)

    if elements.present? && elements.first.present?
      puts elements.first.to_xhtml(indent: 2) # Fix: Use `elements.first` for the first match
    end

    puts
    puts
  end

  # Get all elements by text content
  def get_elements_by_contents(html, text, exact: false)
    elements = find_elements_by_text(html, text, exact: exact)

    elements.each do |element|
      puts element.to_xhtml(indent: 2) if element.present? # Iterate and print each element
    end

    puts
    puts
  end

  # Get the flash area
  def get_flash(html)
     get_element_by_id(html, 'flash')
  end
end
