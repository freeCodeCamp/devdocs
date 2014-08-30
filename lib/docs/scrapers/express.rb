module Docs
  class Express < UrlScraper
    self.name = 'Express'
    self.type = 'express'
    self.version = '4.8.7'
    self.base_url = 'http://expressjs.com/4x/api.html'

    html_filters.push 'express/clean_html', 'express/entries', 'title'

    options[:title] = 'Express'
    options[:container] = '#right'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2014 TJ Holowaychuk<br>
      Licensed under the MIT License.
    HTML
  end
end
