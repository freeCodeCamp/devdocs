module Docs
  class Haskell < UrlScraper
    self.name = 'Haskell'
    self.type = 'haskell'
    self.root_path = 'users_guide/index.html'
    self.initial_paths = %w(libraries/index.html)
    self.links = {
      home: 'https://www.haskell.org/'
    }

    html_filters.push 'haskell/entries', 'haskell/clean_html'

    options[:container] = ->(filter) {filter.subpath.start_with?('users_guide') ? '.body' : '#content'}

    options[:only_patterns] = [/\Alibraries\//, /\Ausers_guide\//]
    options[:skip_patterns] = [
      /-notes/,
      /editing-guide/,
      /src\//,
      /doc-index/,
      /haskell2010/,
      /ghc-/,
      /Cabal-/,
      /Compiler-Hoopl-Internals\.html\z/i,
      /Control-Exception-Base\.html\z/i,
      /Data-Binary-Get-Internal\.html\z/i,
      /Language-Haskell-TH-Lib\.html\z/i,
      /Text-PrettyPrint\.html\z/i,
      /Data-OldTypeable-Internal\.html\z/i,
      /Data-Typeable-Internal\.html\z/i,
      /GHC-IO-Encoding-Types\.html\z/i,
      /System-Posix-Process-Internals\.html\z/i,
      /Data-Map-Strict-Internal\.html\z/i,
      /Data-IntMap-Internal\.html\z/i,
      /Data-Set-Internal\.html\z/i,
      /Data-Map-Internal\.html\z/i,
      /Data-Sequence-Internal\.html\z/i
    ]
    options[:skip] = %w(
      users_guide/license.html
      users_guide/genindex.html
      users_guide/search.html
    )

    options[:attribution] = ->(filter) do
      if filter.subpath.start_with?('users_guide')
        <<-HTML
          &copy; 2002&ndash;2007 The University Court of the University of Glasgow. All rights reserved.<br>
          Licensed under the Glasgow Haskell Compiler License.
        HTML
      else
        <<-HTML
          &copy; The University of Glasgow and others<br>
          Licensed under a BSD-style license (see top of the page).
        HTML
      end
    end

    version '8' do
      self.release = '8.6.1'
      self.base_url = "https://downloads.haskell.org/~ghc/#{release}/docs/html/"
    end

    version '7' do
      self.release = '7.10.3'
      self.base_url = "https://downloads.haskell.org/~ghc/#{release}/docs/html/"
      self.root_path = 'libraries/index.html'

      options[:only_patterns] = [/\Alibraries\//]
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://downloads.haskell.org/~ghc/latest/docs/html/', opts)
      links = doc.css('a').to_a
      versions = links.map {|link| link['href'].scan(/ghc-([0-9.]+)/)}
      versions.find {|version| !version.empty?}[0][0]
    end
  end
end
