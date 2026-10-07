module Docs
  class Tanstack < UrlScraper
    self.abstract = true
    self.type = 'simple'

    html_filters.push 'tanstack/entries', 'tanstack/clean_html'

    options[:attribution] = <<-HTML
      &copy; 2021-present Tanner Linsley<br>
      Licensed under the MIT License.
    HTML

    private

    # tanstack.com sometimes stalls a connection, which hangs the crawl without a timeout
    def request_options
      super.merge(timeout: 60, connecttimeout: 15)
    end
  end
end
