require "net/http"
require "json"

# Checks text for spelling and grammar problems with LanguageTool
# (https://languagetool.org), a free, open-source checker.
#
# By default the text goes to LanguageTool's public service, which allows a
# limited amount of text a minute. To keep the text on your own server, run
# LanguageTool yourself (for example the erikvl87/languagetool Docker image)
# and set LANGUAGETOOL_URL to it, such as http://localhost:8010.
class GrammarCheck
  class Error < StandardError; end

  DEFAULT_URL = "https://api.languagetool.org".freeze
  MAX_CHARACTERS = 20_000
  MAX_REPLACEMENTS = 5

  def self.url
    ENV["LANGUAGETOOL_URL"].presence || DEFAULT_URL
  end

  def self.language
    ENV["LANGUAGETOOL_LANGUAGE"].presence || "en-US"
  end

  # The problems found, each as { offset:, length:, message:, short_message:,
  # replacements:, rule:, kind: }; offsets count characters as JavaScript does.
  def self.check(text)
    text = text.to_s
    return [] if text.strip.empty?
    raise Error, "The text is too long to check at once (#{MAX_CHARACTERS} characters at most)." if text.length > MAX_CHARACTERS

    uri = URI.join(url.end_with?("/") ? url : "#{url}/", "v2/check")
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 20) do |http|
      request = Net::HTTP::Post.new(uri)
      request.set_form_data(text: text, language: language)
      http.request(request)
    end
    if response.code == "429"
      raise Error, "The spelling and grammar checker is busy. Wait a minute and try again."
    end
    raise Error, "The spelling and grammar checker could not be reached (#{response.code})." unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body).fetch("matches", []).map { |match| problem(match) }
  rescue JSON::ParserError, Net::OpenTimeout, Net::ReadTimeout, SocketError, SystemCallError, OpenSSL::SSL::SSLError => error
    Rails.logger.warn("GrammarCheck failed: #{error.class}: #{error.message}")
    raise Error, "The spelling and grammar checker could not be reached. Try again later."
  end

  def self.problem(match)
    rule = match["rule"] || {}
    {
      offset: match["offset"].to_i,
      length: match["length"].to_i,
      message: match["message"].to_s,
      short_message: match["shortMessage"].to_s,
      replacements: Array(match["replacements"]).map { |replacement| replacement["value"].to_s }.reject(&:empty?).first(MAX_REPLACEMENTS),
      rule: rule["id"].to_s,
      kind: rule.dig("category", "id") == "TYPOS" ? "spelling" : "grammar"
    }
  end
  private_class_method :problem
end
