module Docs
  class Sqlite < UrlScraper
    self.name = 'SQLite'
    self.type = 'sqlite'
    self.release = '3.43.0'
    self.base_url = 'https://sqlite.org/'
    self.root_path = 'docs.html'
    self.initial_paths = %w(keyword_index.html)
    self.links = {
      home: 'https://sqlite.org/',
      code: 'https://www.sqlite.org/src/'
    }

    html_filters.insert_before 'clean_html', 'sqlite/clean_js_tables'
    html_filters.push 'sqlite/entries', 'sqlite/clean_html'

    options[:clean_text] = false  # keep SVG elements
    options[:only_patterns] = [/\.html\z/]
    options[:skip_patterns] = [/releaselog/, /consortium/]
    options[:skip] = %w(
      index.html
      about.html
      download.html
      copyright.html
      support.html
      prosupport.html
      hp1.html
      news.html
      oldnews.html
      doclist.html
      dev.html
      chronology.html
      not-found.html
      famous.html
      books.html
      crew.html
      mostdeployed.html
      requirements.html
      session/intro.html
      syntax.html
      src/doc/trunk/doc/lemon.html
    )

    options[:attribution] = 'SQLite is in the Public Domain.'

    def get_latest_version(opts)
      doc = fetch_doc('https://sqlite.org/chronology.html', opts)
      doc.at_css('#chrontab > tbody > tr > td:last-child > a').content
    end

    private

    def parse(response)
      response.body.gsub! %r{(<h2[^>]*>[^<]+)</h1>}, '\1</h2>'
      super
    end
  end
end
