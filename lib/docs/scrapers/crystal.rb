module Docs
  class Crystal < UrlScraper
    self.type = 'crystal'
    self.release = '0.26.0'
    self.base_url = 'https://crystal-lang.org/'
    self.root_path = "api/#{release}/index.html"
    self.initial_paths = %w(docs/index.html)
    self.links = {
      home: 'https://crystal-lang.org/',
      code: 'https://github.com/crystal-lang/crystal'
    }

    html_filters.push 'crystal/entries', 'crystal/clean_html'

    options[:only_patterns] = [/\Adocs\//, /\Aapi\/#{release}\//]
    options[:skip_patterns] = [/debug/i]

    options[:replace_paths] = {
      "api/#{release}/" => "api/#{release}/index.html",
      'docs/' => 'docs/index.html'
    }

    options[:attribution] = ->(filter) {
      if filter.slug.start_with?('docs')
        <<-HTML
          To the extent possible under law, the persons who contributed to this work
          have waived<br>all copyright and related or neighboring rights to this work
          by associating CC0 with it.
        HTML
      else
        <<-HTML
          &copy; 2012&ndash;2018 Manas Technology Solutions.<br>
          Licensed under the Apache License, Version 2.0.
        HTML
      end
    }
  end
end
