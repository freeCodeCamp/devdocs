module Docs
  class Rethinkdb < UrlScraper
    self.name = 'RethinkDB'
    self.type = 'rethinkdb'
    self.version = '1.16.0'
    self.base_url = 'http://rethinkdb.com/api/javascript/'

    html_filters.push 'rethinkdb/entries', 'rethinkdb/clean_html'

    options[:trailing_slash] = false
    options[:container] = '.container .section'

    options[:fix_urls] = ->(url) do
      url.sub! %r{rethinkdb.com/api/(?!javascript|ruby|python)}, 'rethinkdb.com/api/javascript/'
    end

    options[:attribution] = <<-HTML
      &copy; RethinkDB contributors<br>
      Licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
    HTML
  end
end
