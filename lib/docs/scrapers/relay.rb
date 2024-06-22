module Docs
  class Relay < UrlScraper
    self.type = 'simple'
    self.root_path = 'introduction-to-relay'
    self.links = {
      home: 'https://relay.dev/',
      code: 'https://github.com/facebook/relay'
    }

    html_filters.push 'relay/entries', 'relay/clean_html'

    options[:skip] = %w(videos)

    options[:attribution] = <<-HTML
      &copy; 2020&ndash;present Facebook Inc.<br>
      Licensed under the BSD License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('facebook', 'relay', opts)
    end

    version '10' do
      self.release = '10.1.0'
      self.base_url = "https://relay.dev/docs/en/"
      # For some reason, the most-recent version isn't available at a versioned URL
    end

    version '9' do
      self.release = '9.1.0'
      self.base_url = "https://relay.dev/docs/en/v#{self.release}/"
    end

    version '8' do
      self.release = '8.0.0'
      self.base_url = "https://relay.dev/docs/en/v#{self.release}/"
    end

  end
end
