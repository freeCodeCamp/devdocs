module Docs
  class Nim < UrlScraper
    self.type = 'simple'
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

    version '0.19.0' do
      self.release = '0.19.0'
      self.base_url = 'https://nim-lang.org/docs/'
    end

    version 'devel' do
      self.release = 'devel'
      self.base_url = 'https://nim-lang.github.io/Nim/'
    end
  end
end
