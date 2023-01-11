module Docs
  class Jest < UrlScraper
    include MultipleBaseUrls
    self.type = 'simple'
    self.release = '29.0.1'

    self.base_urls = [
      'https://jestjs.io/docs/',
      'https://jestjs.io/docs/expect'
    ]

    self.root_path = 'getting-started'
    self.links = {
      home: 'https://jestjs.io/',
      code: 'https://github.com/facebook/jest'
    }

    html_filters.push 'jest/entries', 'jest/clean_html'

    options[:skip_patterns] = [
      /^next/,
      /upgrading-to-/,
      /\d+\.[x\d]/ # avoid deprecated versions
    ]

    options[:attribution] = <<-HTML
      &copy; 2022 Facebook, Inc.<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      doc = get_latest_github_release('facebook', 'jest', opts)
    end

  end
end
