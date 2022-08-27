module Docs
  class Homebrew < UrlScraper
    self.name = 'Homebrew'
    self.type = 'simple'
    self.release = '3.5.10'
    self.base_url = 'https://docs.brew.sh/'
    self.links = {
      home: 'https://brew.sh',
      code: 'https://github.com/Homebrew/brew'
    }

    html_filters.push 'homebrew/entries', 'homebrew/clean_html'

    options[:container] = ->(filter) { filter.root_page? ? '#home' : '#page' }

    options[:skip_patterns] = [/maintainer/i, /core\-contributor/i, /kickstarter/i, /governance/i]

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;present Homebrew contributors<br>
      Licensed under the BSD 2-Clause License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('Homebrew', 'brew', opts)
    end
  end
end
