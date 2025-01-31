module Validation
  require 'nokogiri'

  extend ActiveSupport::Concern

  private

  def validate_html(html_string, field)
    begin
      # Parse the HTML
      document = Nokogiri::HTML::Document.parse(html_string) do |config|
        config.strict
      end

      if document.errors.any?
        message = ""

        document.errors.each do |error|
          message << "Error at line #{error.line}, column #{error.column}: #{error.message}"
        end

        raise "Invalid HTML\n#{message}"
      elsif document.xpath("//*").any? { |node| node.text.include?("Invalid") }
        raise "Invalid HTML."
      end

      true # HTML is valid
    rescue => e
      errors.add(field, e.message)
      Rails.logger.error("*** HTML Validation Error: #{e.message} ***")
      false # HTML is invalid
    end
  end

  def validate_checksum(checksum, data)
    return true unless data.present?

    checksum == generate_checksum(data)
  end
end
