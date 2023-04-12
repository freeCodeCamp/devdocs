module Docs
  class Redis < UrlScraper
    self.type = 'redis'
    self.release = '7.0.10'
    self.base_url = 'https://redis.io/commands'
    self.links = {
      home: 'https://redis.io/',
      code: 'https://github.com/redis/redis'
    }

    html_filters.push 'redis/entries', 'redis/clean_html', 'title'

    options[:container] = ->(filter) { filter.root_page? ? '#commands-grid' : 'section' }
    options[:title] = false
    options[:root_title] = 'Redis'
    options[:follow_links] = ->(filter) { filter.root_page? }

    options[:attribution] = <<-HTML
      &copy; 2006&ndash;2022 Salvatore Sanfilippo<br>
      Licensed under the Creative Commons Attribution-ShareAlike License 4.0.
    HTML

    def get_latest_version(opts)
      body = fetch('http://download.redis.io/redis-stable/00-RELEASENOTES', opts)
      body = body.lines[1..-1].join
      body.scan(/Redis ([0-9.]+)/)[0][0]
    end

    private

    def parse(response)
      response.body.gsub! '<form', '<pre'
      response.body.gsub! '</form', '</pre'
      super
    end
  end
end
