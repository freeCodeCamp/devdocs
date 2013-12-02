module Docs
  class Less < UrlScraper
    self.type = 'less'
    self.version = '1.5.0'
    self.base_url = 'http://lesscss.org'

    html_filters.push 'less/clean_html', 'less/entries', 'title'

    options[:title] = 'LESS'
    options[:container] = 'section'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2013 Alexis Sellier &amp; The Core Less Team<br>
      Licensed under the Apache License v2.0.
    HTML
  end
end
