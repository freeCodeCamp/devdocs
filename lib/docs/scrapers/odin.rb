module Docs
    class Odin < UrlScraper
      include MultipleBaseUrls
      self.name = 'Odin'
      self.slug = 'odin'
      self.type = 'odin'
      self.release = 'latest'
      self.base_urls = [ 
        'https://odin-lang.org/',
        'https://pkg.odin-lang.org/'
      ]

      def initial_urls
        [ 
          'https://odin-lang.org/docs',
          'https://odin-lang.org/spec',
          'https://pkg.odin-lang.org/base',
          'https://pkg.odin-lang.org/core',
          'https://pkg.odin-lang.org/vendor'
        ]
      end

      self.root_path = 'https://odin-lang.org/'
      self.initial_paths = %w(base core vendor)

      self.links = {
        home: 'https://odin-lang.org/',
        code: 'https://github.com/odin-lang/Odin'
      }

      html_filters.push 'odin/entries', 'odin/clean_html'
      options[:download_images] = false

      options[:container] = '.odin-main'

      options[:only_patterns] = [
        /docs/,
        /spec/,
        /base/,
        /core/,
        /vendor/
      ]
      options[:trailing_slash] = false
      options[:skip] = %w(
        docs/examples 
        docs/nightly
        docs/odin-book
        docs/spec
        docs/packages
      )
      
      options[:attribution] = <<-HTML
        &copy; 2016-#{Date.today.year} Ginger Bill<br>
        Licensed under the zlib License.
      HTML

    end
end
