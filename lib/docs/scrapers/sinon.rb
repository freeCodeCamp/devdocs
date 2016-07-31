module Docs
  class Sinon < UrlScraper
    self.name = 'Sinon'
    self.type = 'sinon'
    self.release = '1.17.5'
    self.base_url = 'http://sinonjs.org/docs/'
    self.links = {
      home: 'http://sinonjs.org/',
      code: 'https://github.com/cjohansen/Sinon.JS'
    }

    html_filters.push 'sinon/clean_html', 'sinon/entries', 'title'

    options[:title] = 'Sinon.JS'
    options[:container] = '.docs'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2016 Christian Johansen<br>
      Licensed under the BSD License.
    HTML
  end
end
