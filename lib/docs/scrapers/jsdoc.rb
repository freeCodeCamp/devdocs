module Docs
  class Jsdoc < UrlScraper
    self.name = 'JSDoc'
    self.type = 'jsdoc'
    self.release = '3.5.5'
    self.base_url = 'http://usejsdoc.org/'
    self.links = {
      home: 'http://usejsdoc.org/',
      code: 'https://github.com/jsdoc3/jsdoc'
    }

    html_filters.push 'jsdoc/clean_html', 'jsdoc/entries'

    options[:trailing_slash] = false
    options[:container] = 'article'
    options[:skip] = [
      'about-license-jsdoc3.html'
    ]
    options[:attribution] = <<-HTML
      &copy; 2011&ndash;2017
        <a href="https://github.com/jsdoc3/jsdoc3.github.com/contributors">
          JSDoc 3 contributors
        </a><br>
      Licensed under
        <a href="http://creativecommons.org/licenses/by-sa/3.0/">
          CC BY-SA 3.0
        </a>
    HTML
  end
end
