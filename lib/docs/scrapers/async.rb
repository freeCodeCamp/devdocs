module Docs
  class Async < UrlScraper
    self.type = 'async'
    self.release = '3.0.1'
    self.base_url = 'https://caolan.github.io/async/v3/'
    self.root_path = 'docs.html'
    self.links = {
      home: 'https://caolan.github.io/async/',
      code: 'https://github.com/caolan/async'
    }

    html_filters.push 'async/entries', 'async/clean_html'

    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2018 Caolan McMahon<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://caolan.github.io/async/v3/', opts)
      doc.at_css('#version-dropdown > a').content.strip[1..-1]
    end
  end
end
