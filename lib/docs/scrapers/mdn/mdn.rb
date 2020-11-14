module Docs
  class Mdn < UrlScraper
    self.abstract = true
    self.type = 'mdn'

    params[:raw] = 1
    params[:macros] = 1

    html_filters.push 'mdn/clean_html'
    text_filters.insert_before 'attribution', 'mdn/contribute_link'

    options[:rate_limit] = 200
    options[:trailing_slash] = false

    options[:skip_link] = ->(link) {
      link['title'].try(:include?, 'not yet been written'.freeze) && !link['href'].try(:include?, 'transform-function'.freeze)
    }

    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2020 Mozilla and individual contributors.<br>
      Licensed under the Creative Commons Attribution-ShareAlike License v2.5 or later.
    HTML

    def get_latest_version(opts)
      json = fetch_json("https://developer.mozilla.org/en-US/docs/feeds/json/tag/#{options[:mdn_tag]}", opts)
      dates = json.map { |i| i['pubdate'] }
      DateTime.parse(dates.max).to_time.to_i
    end

    private

    def process_response?(response)
      response.effective_url.host = 'developer.mozilla.org' if response.effective_url.host == 'wiki.developer.mozilla.org'
      super && response.effective_url.query == 'raw=1&macros=1'
    end
  end
end
