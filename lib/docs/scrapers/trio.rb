module Docs
  class Trio < UrlScraper
    self.type = 'simple'
    self.release = '0.11'
    self.base_url = 'https://trio.readthedocs.io/en/latest/'
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
      &copy; 2017-2019 Nathaniel Smith<br>
      Licensed under MIT and Apache2.
    HTML

  end
end
