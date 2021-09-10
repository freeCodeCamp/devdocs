module Docs
  class Crystal < UrlScraper
    self.type = 'crystal'
    self.base_url = 'https://crystal-lang.org/'
    self.initial_paths = %w(reference/index.html)
    self.links = {
      home: 'https://crystal-lang.org/',
      code: 'https://github.com/crystal-lang/crystal'
    }

    html_filters.push 'crystal/entries', 'crystal/clean_html'

    options[:attribution] = ->(filter) {
      if filter.slug.start_with?('reference')
        <<-HTML
          To the extent possible under law, the persons who contributed to this work
          have waived<br>all copyright and related or neighboring rights to this work
          by associating CC0 with it.
        HTML
      else
        <<-HTML
          &copy; 2012&ndash;2021 Manas Technology Solutions.<br>
          Licensed under the Apache License, Version 2.0.
        HTML
      end
    }

    self.release = '1.1.1'
    self.root_path = "api/#{release}/index.html"

    options[:only_patterns] = [/\Aapi\/#{release}\//, /\Areference\//]
    options[:skip_patterns] = [/debug/i]

    options[:replace_paths] = {
      "api/#{release}/" => "api/#{release}/index.html",
      'reference/' => 'reference/index.html'
    }

    def get_latest_version(opts)
      doc = fetch_doc('https://crystal-lang.org/', opts)
      doc.at_css('.latest-release').content.scan(/([0-9.]+)/)[0][0]
    end
  end
end
