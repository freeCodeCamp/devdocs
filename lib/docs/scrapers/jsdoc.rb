module Docs
  class Jsdoc < UrlScraper
    self.name = 'JSDoc'
    self.type = 'simple'
    self.release = '3.6.7'
    self.base_url = 'https://jsdoc.app/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://jsdoc.app/',
      code: 'https://github.com/jsdoc/jsdoc'
    }

    html_filters.push 'jsdoc/clean_html', 'jsdoc/entries'

    options[:trailing_slash] = false
    options[:container] = 'article'
    options[:skip] = [
      'about-license-jsdoc3.html'
    ]
    options[:attribution] = <<-HTML
      &copy; 2011&ndash;2017 the contributors to the JSDoc 3 documentation project<br>
      Licensed under the Creative Commons Attribution-ShareAlike Unported License v3.0.
    HTML

    def get_latest_version(opts)
      get_npm_version('jsdoc', opts)
    end
  end
end
