module Docs
    class OdinPackages < UrlScraper
        self.name = 'Odin Packages'
        self.slug = 'odin_packages'
        self.type = 'odin_packages'
        self.release = 'latest'
        self.base_url = 'https://pkg.odin-lang.org/'
        # self.root_path = 'https://pkg.odin-lang.org/'
        self.initial_paths = %w(base core vendor)

        options[:trailing_slash] = false
          
        self.links = {
          home: 'https://odin-lang.org/',
          code: 'https://github.com/odin-lang/Odin'
        }

        html_filters.push 'odin_packages/entries', 'odin_packages/clean_html'

        options[:download_images] = false
        options[:container] = '.odin-main'

        options[:attribution] = <<-HTML
          &copy; 2016-#{Date.today.year} Ginger Bill<br>
          Licensed under the 3-clause BSD License.
        HTML

    end
end
