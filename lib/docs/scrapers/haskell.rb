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
      # The .Internal modules re-export what the public ones do, so they only
      # double every entry. They also rarely declare a type of their own, which
      # leaves their entries without the context the entries filter appends.
      /-Internals?[-.]/,
      /Control-Exception-Base\.html\z/i,
      /Language-Haskell-TH-Lib\.html\z/i,
      /Text-PrettyPrint\.html\z/i,
      /GHC-IO-Encoding-Types\.html\z/i
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
      # so download one of them and extract that directory alone.
      def download_source
        release = self.class.release
        download_and_extract(
          "https://downloads.haskell.org/~ghc/#{release}/ghc-#{release}-x86_64-alpine3_22-linux.tar.xz",
          # The directory inside the tarball uses a different triple than its name.
          "ghc-#{release}-x86_64-unknown-linux/doc/html")
        rename_libraries
      end

      # None of the published binary distributions comes from the build behind
      # the documentation served under docs/, so their library directories
      # carry a different hash. Rename the extracted ones after the published
      # ones and rewrite the links between them, otherwise every page would
      # point its attribution link at a URL that doesn't exist.
      def rename_libraries
        renames = library_renames
        return if renames.empty?

        instrument 'info.doc', msg: %(Renaming #{renames.size} library directories after the published documentation...)
        renames.each do |from, to|
          File.rename(File.join(libraries_directory, from), File.join(libraries_directory, to))
        end

        pattern = Regexp.union(renames.keys)
        Dir.glob(File.join(source_directory, '**', '*.html')) do |path|
          html = File.read(path)
          fixed = html.gsub(pattern, renames)
          File.write(path, fixed) unless fixed == html
        end
      end

      # Maps the name of each extracted library directory to the one the same
      # package and version are published under. Directories the published
      # documentation doesn't list, such as the ghc-* ones, are left alone.
      def library_renames
        extracted = Dir.children(libraries_directory)
          .select { |name| File.directory?(File.join(libraries_directory, name)) }
          .index_by { |name| library_name(name) }

        published_libraries.filter_map do |name|
          from = extracted[library_name(name)]
          [from, name] if from && from != name
        end.to_h
      end

      def published_libraries
        url = "#{self.class.base_url}libraries/index.html"
        response = Request.run(url)
        raise SetupError, %(Failed to download "#{url}".) unless response.success?

        response.body.scan(%r{href="([^"/]+-\h+)/}).flatten.uniq
      end

      # Haddock appends a per-build hash to every library directory.
      def library_name(directory)
        directory.sub(/-\h+\z/, '')
      end

      def libraries_directory
        File.join(source_directory, 'libraries')
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
