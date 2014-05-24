module Docs
  class Haskell < UrlScraper
    self.name = 'Haskell'
    self.slug = 'haskell'
    self.type = 'haskell'
    self.version = '7.8.2'
    self.base_url = 'http://www.haskell.org/ghc/docs/7.8.2/html/libraries/'
    self.initial_paths = ['/index.html']

    html_filters.push 'haskell/entries'
    html_filters.push 'haskell/clean_html'
    html_filters.push 'title'


    options[:container]     = '#content'
    options[:skip_patterns] = [/src/, /index/, /haskell2010/, /ghc-/, /Cabal-/]   # skip source listings and index files

    options[:attribution] = <<-HTML
      &copy; The University Court of the University of Glasgow.<br>
      All rights reserved. <a href="http://www.haskell.org/ghc/license">See here for more info</a>
    HTML

    end
end
