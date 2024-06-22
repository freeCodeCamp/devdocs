module Docs
  class Codeception < UrlScraper
    self.name = 'Codeception'
    self.type = 'codeception'
    self.release = '4.1.22'
    self.base_url = 'https://codeception.com/docs/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://codeception.com/',
      code: 'https://github.com/Codeception/Codeception'
    }

    html_filters.push 'codeception/entries', 'codeception/clean_html'

    options[:skip_patterns] = [/install/]

    options[:attribution] = <<-HTML
      &copy; 2011 Michael Bodnarchuk and contributors<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_github_tags("Codeception", "Codeception", opts)[1]["name"]
    end
  end
end
