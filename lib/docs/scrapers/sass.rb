module Docs
  class Sass < UrlScraper
    self.type = 'yard'
    self.release = '3.6.4'
    self.base_url = 'https://sass-lang.com/documentation'
    self.root_path = 'index.html'
    self.links = {
      home: 'http://sass-lang.com/',
      code: 'https://github.com/sass/sass'
    }

    html_filters.push 'sass/clean_html', 'sass/entries', 'title'

    options[:root_title] = false
    options[:title] = 'Sass Functions'

    options[:skip_patterns] = [/breaking-changes/]

    # options[:container] = '#main-content'

    options[:attribution] = <<-HTML
      &copy; 2006&ndash;2020 Hampton Catlin, Nathan Weizenbaum, and Chris Eppstein<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('sass', 'libsass', opts)
    end

  end
end
