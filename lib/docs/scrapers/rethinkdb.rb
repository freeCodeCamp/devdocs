module Docs
  class Rethinkdb < UrlScraper
    self.name = 'RethinkDB'
    self.type = 'rethinkdb'
    self.release = '2.3.2'
    self.links = {
      home: 'https://rethinkdb.com/',
      code: 'https://github.com/rethinkdb/rethinkdb'
    }

    html_filters.push 'rethinkdb/entries', 'rethinkdb/clean_html'

    options[:trailing_slash] = false
    options[:container] = '.docs-article'

    options[:attribution] = <<-HTML
      &copy; RethinkDB contributors<br>
      Licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
    HTML

    version 'JavaScript' do
      self.base_url = 'https://rethinkdb.com/api/javascript/'

      options[:fix_urls] = ->(url) do
        url.sub! %r{rethinkdb.com/api/(?!javascript|ruby|python|java)}, 'rethinkdb.com/api/javascript/'
      end
    end

    version 'Ruby' do
      self.base_url = 'https://rethinkdb.com/api/ruby/'

      options[:fix_urls] = ->(url) do
        url.sub! %r{rethinkdb.com/api/(?!javascript|ruby|python|java)}, 'rethinkdb.com/api/ruby/'
      end
    end

    version 'Python' do
      self.base_url = 'https://rethinkdb.com/api/python/'

      options[:fix_urls] = ->(url) do
        url.sub! %r{rethinkdb.com/api/(?!javascript|ruby|python|java)}, 'rethinkdb.com/api/python/'
      end
    end

    version 'Java' do
      self.base_url = 'https://rethinkdb.com/api/java/'

      options[:fix_urls] = ->(url) do
        url.sub! %r{rethinkdb.com/api/(?!javascript|ruby|python|java)}, 'rethinkdb.com/api/java/'
      end
    end
  end
end
