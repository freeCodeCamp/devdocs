module Docs
  class Marionette < UrlScraper
    self.name = 'Marionette.js'
    self.slug = 'marionette'
    self.type = 'marionette'
    self.release = '2.4.7'
    self.base_url = "http://marionettejs.com/docs/v#{release}/"
    self.root_path = 'index'
    self.links = {
      home: 'http://marionettejs.com/',
      code: 'https://github.com/marionettejs/backbone.marionette'
    }

    html_filters.push 'marionette/clean_html', 'marionette/entries'

    options[:container] = '.docs__content'

    options[:attribution] = <<-HTML
      &copy; 2016 Muted Solutions, LLC<br>
      Licensed under the MIT License.
    HTML
  end
end
