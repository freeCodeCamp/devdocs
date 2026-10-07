module Docs
  # Namespace for the filters shared by the TanStack documentations.
  # Abstract so `thor docs:list` does not offer it as a doc of its own.
  class Tanstack < UrlScraper
    self.abstract = true
    self.type = 'simple'

    # Container stays `body` so the sidebar is still in the document when
    # InternalUrlsFilter queues links. The clean filter then keeps the h1 and `.prose`.
    html_filters.push 'tanstack/entries', 'tanstack/clean_html'

    options[:attribution] = <<-HTML
      &copy; 2021-present Tanner Linsley<br>
      Licensed under the MIT License.
    HTML

    private

    # Typhoeus waits forever on a read. A stalled HTTP/2 connection to
    # tanstack.com otherwise blocks the crawl with no further pages written.
    def request_options
      super.merge(timeout: 60, connecttimeout: 15)
    end
  end
end
