module Docs
  class Flow < UrlScraper
    self.type = 'simple'
    self.release = '0.186.0'
    self.base_url = 'https://flow.org/en/docs/'
    self.links = {
      home: 'https://flow.org/',
      code: 'https://github.com/facebook/flow'
    }

    html_filters.push 'flow/entries', 'flow/clean_html', 'title'

    options[:trailing_slash] = false
    options[:root_title] = 'Flow'
    options[:skip] = %w(libs install)

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;present Facebook Inc.<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_npm_version('flow-bin', opts)
    end
  end
end
