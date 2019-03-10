module Docs
  class Backbone < UrlScraper
    self.name = 'Backbone.js'
    self.slug = 'backbone'
    self.type = 'underscore'
    self.release = '1.3.3'
    self.base_url = 'http://backbonejs.org'
    self.links = {
      home: 'http://backbonejs.org/',
      code: 'https://github.com/jashkenas/backbone'
    }

    html_filters.push 'backbone/clean_html', 'backbone/entries', 'title'

    options[:title] = 'Backbone.js'
    options[:container] = '.container'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2016 Jeremy Ashkenas, DocumentCloud<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://backbonejs.org/', opts)
      doc.at_css('.version').content[1...-1]
    end
  end
end
