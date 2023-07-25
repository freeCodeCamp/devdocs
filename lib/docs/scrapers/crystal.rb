module Docs
  class Crystal < UrlScraper
    include MultipleBaseUrls
    self.type = 'crystal'
    self.release = '1.9.2'
    self.base_urls = [
      "https://crystal-lang.org/api/#{release}/",
      "https://crystal-lang.org/reference/#{release[0..2]}/",
    ]
    def initial_urls
      [ "https://crystal-lang.org/api/#{self.class.release}/index.html",
        "https://crystal-lang.org/reference/#{self.class.release[0..2]}/index.html" ]
    end

    self.links = {
      home: 'https://crystal-lang.org/',
      code: 'https://github.com/crystal-lang/crystal'
    }

    html_filters.push 'crystal/entries', 'crystal/clean_html'

    options[:attribution] = ->(filter) {
      if filter.current_url.path.start_with?('/reference/')
        <<-HTML
          To the extent possible under law, the persons who contributed to this work
          have waived<br>all copyright and related or neighboring rights to this work
          by associating CC0 with it.
        HTML
      else
        <<-HTML
          &copy; 2012&ndash;2023 Manas Technology Solutions.<br>
          Licensed under the Apache License, Version 2.0.
        HTML
      end
    }

    def get_latest_version(opts)
      doc = fetch_doc('https://crystal-lang.org/', opts)
      doc.at_css('.latest-release').content.scan(/([0-9.]+)/)[0][0]
    end
  end
end
