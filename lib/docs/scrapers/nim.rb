module Docs
  class Nim < UrlScraper
    self.type = 'nim'
    self.release = '0.17.0'
    self.links = {
      home: 'https://nim-lang.org/',
      code: 'https://github.com/nim-lang/Nim'
    }
    self.base_url = 'https://nim-lang.org/'
    self.root_path = 'docs/overview.html'

    html_filters.push 'nim/entries', 'nim/clean_html' 
    
    options[:skip] = %w(cdn-cgi/l/email-protection docs/theindex.html docs/docgen.txt)
    options[:attribution] = <<-HTML
      &copy; 2006&ndash;2017 Andreas Rumpf<br>
      All rights reserved. Licensed under the MIT License.
    HTML

  end
end