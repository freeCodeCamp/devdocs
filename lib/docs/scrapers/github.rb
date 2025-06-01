module Docs
  class Github < UrlScraper
    self.abstract = true
    self.type = 'github'

    html_filters.push 'github/clean_html'

    def process_response?(response)
      if super(response)
        return true
      end
      JSON.parse(response.body)
      true
    rescue JSON::ParserError, TypeError => e
      false
    end

    def parse(response)
      embedded_json = response
        .response_body
        .match(/react-app\.embeddedData">(.+?)<\/script>/)
        &.captures
        &.first
      parsed = JSON.parse(embedded_json)

      [parsed['payload']['blob']['richText'], parsed['title']]
    end
  end
end
