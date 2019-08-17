module Docs
  class Trio < UrlScraper
    self.type = 'simple'
    self.release = '0.12.1'
    self.base_url = 'https://trio.readthedocs.io/en/v0.12.1/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://trio.readthedocs.io/',
      code: 'https://github.com/python-trio/trio'
    }

    html_filters.push 'trio/entries', 'trio/clean_html'

    options[:only_patterns] = [
      /reference-core/,
      /reference-io/,
      /reference-testing/,
      /reference-hazmat/,
    ]

    options[:attribution] = <<-HTML
      &copy; 2017 Nathaniel J. Smith<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://trio.readthedocs.io/en/stable/', opts)
      doc.at_css('.rst-other-versions a[href^="/en/v"]').content[1..-1]
    end
  end
end
