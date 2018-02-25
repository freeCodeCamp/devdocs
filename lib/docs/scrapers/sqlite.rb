module Docs
  class Sqlite < FileScraper
    self.name = 'SQLite'
    self.type = 'sqlite'
    self.release = '3.22.0'
    self.dir = '/Users/Thibaut/DevDocs/Docs/sqlite/'
    self.base_url = 'https://sqlite.org/'
    self.root_path = 'docs.html'
    self.initial_paths = %w(keyword_index.html)
    self.links = {
      home: 'https://sqlite.org/',
      code: 'https://www.sqlite.org/src/'
    }

    html_filters.insert_before 'clean_html', 'sqlite/clean_js_tables'
    html_filters.push 'sqlite/entries', 'sqlite/clean_html'

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
    )

    options[:attribution] = 'SQLite is in the Public Domain.'

    private

    def parse(response)
      response.body.gsub! %r{(<h2[^>]*>[^<]+)</h1>}, '\1</h2>'
      super
    end
  end
end
