module Docs
  class Handlebars < UrlScraper
    self.name = 'Handlebars.js'
    self.slug = 'handlebars'
    self.type = 'simple'
    self.release = '4.0.12'
    self.base_url = 'https://handlebarsjs.com/'
    self.links = {
      home: 'https://handlebarsjs.com/',
      code: 'https://github.com/wycats/handlebars.js/'
    }

    html_filters.push 'handlebars/entries', 'handlebars/clean_html', 'title'

    options[:container] = '#contents'
    options[:root_title] = 'Handlebars.js'

    options[:attribution] = <<-HTML
      &copy; 2011&ndash;2017 by Yehuda Katz<br>
      Licensed under the MIT License.
    HTML
  end
end
