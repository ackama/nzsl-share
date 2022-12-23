# frozen_string_literal: true

class Sanitizer
  class << self
    def sanitize(input = "")
      input = ActionController::Base.helpers.sanitize(input)
      input = ActionController::Base.helpers.strip_links(input)
      ActionController::Base.helpers.strip_tags(input)
    end

    def sanitize_text_with_urls(input = "")
      sanitize(input).gsub(URI::DEFAULT_PARSER.make_regexp) { |url| sanitize_url(url) }
    end

    def sanitize_url(input = "")
      url = CGI.unescape(input)
      uri = URI.parse(url)

      return unless uri.scheme.downcase.match?(/\A(http|https)\Z/)
      return sanitize(url) unless uri.query

      query = sanitize(CGI.unescape(uri.query)) # double encoded?

      "#{uri.scheme}://#{uri.host}#{uri.path || ""}?#{CGI.escape(query)}"
    end
  end
end
