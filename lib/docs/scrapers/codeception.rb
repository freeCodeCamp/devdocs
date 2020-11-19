module Docs
  class Codeception < UrlScraper
    self.name = 'Codeception'
    self.type = 'codeception'
    self.release = '4.1.12'
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
      doc = fetch_doc('https://codeception.com/changelog', opts)
      doc.at_css('#page > h4').content
    end
  end
end
