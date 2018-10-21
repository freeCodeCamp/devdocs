module Docs
  class Graphite < UrlScraper
    self.type = 'graphite'
    self.release = '1.1.3'
    self.base_url = 'https://graphite.readthedocs.io/en/latest/'
    self.links = {
      code: 'https://github.com/graphite-project/graphite-web'
    }

    html_filters.push 'graphite/entries', 'graphite/clean_html'

    options[:container] = '.document > div'
    options[:skip] = %w(releases.html who-is-using.html composer.html search.html py-modindex.html genindex.html)

    options[:attribution] = <<-HTML
      &copy; 2008&ndash;2012 Chris Davis<br>
      &copy; 2011&ndash;2016 The Graphite Project<br>
      Licensed under the Apache License, Version 2.0.
    HTML
  end
end
