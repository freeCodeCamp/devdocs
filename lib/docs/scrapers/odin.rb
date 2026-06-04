module Docs
    class Odin < UrlScraper
        self.name = 'Odin'
        self.slug = 'odin'
        self.type = 'odin'
        self.release = 'latest'
        self.base_url = 'https://odin-lang.org/'
        self.root_path = 'https://odin-lang.org/'
        self.initial_paths = %w(docs spec)
          
        self.links = {
          home: 'https://odin-lang.org/',
          code: 'https://github.com/odin-lang/Odin'
        }
  
        html_filters.push 'odin/entries', 'odin/clean_html'
        options[:download_images] = false

        options[:container] = '.odin-main'

        options[:only_patterns] = [/docs/, /spec/]
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
          Licensed under the 3-clause BSD License.
        HTML

    end
end
