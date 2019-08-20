module Docs
  class Jest < UrlScraper
    self.type = 'simple'
    self.release = '24.9'
    self.base_url = 'https://jestjs.io/docs/en/'
    self.root_path = 'getting-started'
    self.links = {
      home: 'https://jestjs.io/',
      code: 'https://github.com/facebook/jest'
    }

    html_filters.push 'jest/entries', 'jest/clean_html'

    options[:container] = '.docMainWrapper'

    options[:attribution] = <<-HTML
      &copy; 2019 Facebook, Inc. and its affiliates.<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://jestjs.io/docs/en/getting-started', opts)
      doc.at_css('header > a > h3').content
    end
  end
end
