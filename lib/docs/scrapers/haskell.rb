module Docs
  class Haskell < FileScraper
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

    version '9' do
      self.release = '9.14.1'
      self.base_url = "https://downloads.haskell.org/~ghc/#{release}/docs/"
      options[:container] = ->(filter) {filter.subpath.start_with?('users_guide') ? '.document' : '#content'}

      private

      # GHC doesn't publish the documentation on its own. The HTML tree served
      # under docs/ also ships inside every binary distribution, under doc/html,
      # so download one of them and extract that directory alone. Note that the
      # library directories are named after a per-build hash, so the paths here
      # differ from the ones of the documentation served under docs/.
      def download_source
        require 'unix_utils'

        release = self.class.release
        url = "https://downloads.haskell.org/~ghc/#{release}/ghc-#{release}-x86_64-alpine3_22-linux.tar.xz"
        # The directory inside the tarball uses a different triple than its name.
        directory = "ghc-#{release}-x86_64-unknown-linux/doc/html"

        instrument 'info.doc', msg: %(Downloading #{url}...)
        archive = UnixUtils.curl(url)

        instrument 'info.doc', msg: %(Extracting the documentation files to "#{source_directory}"...)
        FileUtils.mkpath(source_directory)

        # Extract the documentation directory alone: unpacking the whole
        # distribution through download_and_extract would waste a few gigabytes,
        # and it doesn't know about xz to begin with.
        unless system('tar', '-xJf', archive, '-C', source_directory, '--strip-components=3', directory)
          FileUtils.rm_rf(source_directory)
          raise SetupError, %(Failed to extract "#{directory}" from "#{url}".)
        end
      ensure
        FileUtils.rm_f(archive) if archive
      end
    end

    version '8' do
      self.release = '8.10.2'
      self.base_url = "https://downloads.haskell.org/~ghc/#{release}/docs/html/"
    end

    version '7' do
      self.release = '7.10.3'
      self.base_url = "https://downloads.haskell.org/~ghc/#{release}/docs/html/"
      self.root_path = 'libraries/index.html'

      options[:only_patterns] = [/\Alibraries\//]
    end

    def get_latest_version(opts)
      tags = get_github_tags('ghc', 'ghc', opts)
      tag = tags.find {|t| t['name'].ends_with?('-release') }['name']
      tag[/ghc-(.*)-release/, 1]
    end

  end
end
