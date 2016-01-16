module Docs
  class Q < UrlScraper
    self.name = 'Q'
    self.type = 'q'
    self.release = '1.4.1'
    self.base_url = 'https://github.com/kriskowal/q/wiki/'
    self.root_path = 'API-Reference'
    self.links = {
      home: 'http://documentup.com/kriskowal/q/',
      code: 'https://github.com/kriskowal/q'
    }

    html_filters.push 'q/clean_html', 'q/entries', 'title'

    options[:container] = '.markdown-body'
    options[:title] = 'Q'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2015 Kristopher Michael Kowal and contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
