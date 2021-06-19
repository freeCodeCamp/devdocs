module Docs
  class Nim < UrlScraper
    self.type = 'simple'
    self.release = '1.4.8'
    self.base_url = 'https://nim-lang.org/docs/'
    self.root_path = 'overview.html'
    self.links = {
      home: 'https://nim-lang.org/',
      code: 'https://github.com/nim-lang/Nim'
    }

    html_filters.push 'nim/entries', 'nim/clean_html'

    options[:skip] = %w(theindex.html docgen.html tut1.html tut2.html tut3.html tools.html)

    options[:attribution] = <<-HTML
      &copy; 2006&ndash;2021 Andreas Rumpf<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://nim-lang.org/docs/overview.html', opts)
      doc.at_css('.container > .docinfo > tbody > tr:last-child > td').content.strip
    end
  end
end
