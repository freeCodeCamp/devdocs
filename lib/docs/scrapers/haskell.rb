module Docs
  class Haskell < UrlScraper
    self.name = 'Haskell'
    self.type = 'haskell'
    self.version = '7.8.4'
    self.base_url = 'https://downloads.haskell.org/~ghc/7.8.4/docs/html/libraries/'
    self.root_path = 'index.html'

    html_filters.push 'haskell/entries', 'haskell/clean_html'

    options[:container] = '#content'

    options[:skip] = %w(
      hoopl-3.10.0.1/Compiler-Hoopl-Internals.html
      base-4.7.0.0/Control-Exception-Base.html
      binary-0.7.1.0/Data-Binary-Get-Internal.html
      template-haskell-2.9.0.0/Language-Haskell-TH-Lib.html
      haskell98-2.0.0.3/Prelude.html
      pretty-1.1.1.1/Text-PrettyPrint.html
      base-4.7.0.0/Data-OldTypeable-Internal.html
      base-4.7.0.0/Data-Typeable-Internal.html
      base-4.7.0.0/GHC-IO-Encoding-Types.html
      unix-2.7.0.1/System-Posix-Process-Internals.html)

    options[:skip_patterns] = [/src\//, /doc-index/, /haskell2010/, /ghc-/, /Cabal-/]

    options[:attribution] = <<-HTML
      &copy; The University of Glasgow and others<br>
      Licensed under a BSD-style license (see top of the page).
    HTML
  end
end
