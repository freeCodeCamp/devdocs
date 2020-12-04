module Docs
  class Relay < UrlScraper
    self.type = 'simple'
    self.release = '10.1.0'
    self.base_url = 'https://relay.dev'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://relay.dev/',
      code: 'https://github.com/facebook/relay'
    }

    html_filters.push 'relay/entries', 'relay/clean_html'

    options[:only] = [
      '/docs/en/graphql-in-relay',
      '/docs/en//relay-environment',
      '/docs/en/network-layer',
      '/docs/en/query-renderer',
      '/docs/en/fragment-container',
      '/docs/en/refetch-container',
      '/docs/en/pagination-container',
      '/docs/en/mutations',
      '/docs/en/subscriptions',
      '/docs/en/relay-store',
      '/docs/en/fetch-query'
    ]

    options[:attribution] = <<-HTML
      &copy; 2020&ndash;present Facebook Inc.<br>
      Licensed under the BSD License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('facebook', 'relay', opts)
    end

  end
end
