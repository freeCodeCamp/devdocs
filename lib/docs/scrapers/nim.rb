module Docs
  class Nim < UrlScraper
    self.type = 'simple'
    self.release = '0.19.0'
    self.base_url = 'https://nim-lang.org/docs/'
    self.root_path = 'overview.html'
    self.links = {
      home: 'https://nim-lang.org/',
      code: 'https://github.com/nim-lang/Nim'
    }

    html_filters.push 'nim/entries', 'nim/clean_html'

    options[:skip] = %w(theindex.html docgen.txt)

    options[:attribution] = <<-HTML
      &copy; 2006&ndash;2018 Andreas Rumpf<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://nim-lang.org/docs/overview.html', opts)
      doc.at_css('.container > .docinfo > tbody > tr:last-child > td').content.strip
    end
  end
end
