module Docs
  class Jest < UrlScraper
    self.type = 'simple'
    self.release = '26.6'
    self.base_url = 'https://jestjs.io/docs/en/'
    self.root_path = 'getting-started'
    self.links = {
      home: 'https://jestjs.io/',
      code: 'https://github.com/facebook/jest'
    }

    html_filters.push 'jest/entries', 'jest/clean_html'

    options[:container] = '.docMainWrapper'

    options[:attribution] = <<-HTML
      &copy; 2020 Facebook, Inc.<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      doc = get_latest_github_release('facebook', 'jest', opts)
    end

  end
end
