module Docs
  class Redis < UrlScraper
    self.type = 'redis'
    self.version = 'up to 2.8.5'
    self.base_url = 'http://redis.io/commands'

    html_filters.push 'redis/entries', 'redis/clean_html', 'title'

    options[:container] = ->(filter) { filter.root_page? ? '#commands' : '.text' }
    options[:title] = false
    options[:root_title] = 'Redis'
    options[:follow_links] = ->(filter) { filter.root_page? }

    options[:attribution] = <<-HTML
      &copy; 2006&ndash;2014 Salvatore Sanfilippo and others<br>
      Licensed under the three clause BSD license.
    HTML
  end
end
