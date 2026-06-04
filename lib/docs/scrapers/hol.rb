module Docs
  class Hol < UrlScraper
    self.name = 'Hashgraph Online'
    self.slug = 'hol'
    self.type = 'simple'
    self.release = '0.1.161'
    self.base_url = 'https://hol.org/docs/'
    self.root_path = 'libraries/standards-sdk/'
    self.initial_paths = %w(
      libraries/standards-sdk/
      registry-broker/
    )
    self.links = {
      home: 'https://hol.org/',
      code: 'https://github.com/hashgraph-online/standards-sdk'
    }

    html_filters.push 'hol/entries', 'hol/clean_html'

    options[:trailing_slash] = true
    options[:only_patterns] = [
      %r{\A(?:libraries/standards-sdk|registry-broker)(?:/|$)},
    ]
    options[:skip_patterns] = [
      %r{\Aregistry-broker/examples/(?:chat-demo|ping-agent-demo)/?},
      %r{\Aregistry-broker/getting-started/(?:faq|first-registration|installation|quick-start)/?},
      %r{\Aregistry-broker/(?:feature-your-agent|moltbook|partner-program|skills-upload-discovery|updating-agents)/?},
    ]

    options[:attribution] = <<-HTML
      Copyright &copy; 2025 Hashgraph Online DAO.<br>
      Licensed under the Apache License 2.0.
    HTML

    def get_latest_version(opts)
      get_npm_version('@hashgraphonline/standards-sdk', opts)
    end
  end
end
