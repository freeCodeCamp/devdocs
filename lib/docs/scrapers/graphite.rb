module Docs
  class Graphite < UrlScraper
    self.type = 'graphite'
    self.release = '1.1.3'
    self.base_url = 'http://graphite.readthedocs.io/en/latest/'
    self.links = {
      code: 'https://github.com/graphite-project/graphite-web'
    }

    html_filters.push 'graphite/clean_html', 'graphite/entries'

    options[:container] = '.document > div > .section'
    options[:skip] = %w(releases.html who-is-using.html composer.html)

    options[:attribution] = <<-HTML
      &copy; 2008-2012 Chris Davis; 2011-2016 The Graphite Project<br>
      Licensed under the Apache License, Version 2.0.
    HTML
  end
end
