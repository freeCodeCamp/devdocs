module Docs
  class Codeceptjs < UrlScraper
    self.name = 'CodeceptJS'
    self.type = 'simple'
    self.root_path = 'index.html'
    self.release = '3.0.2'
    self.base_url = 'https://codecept.io/'
    self.links = {
      home: 'https://codecept.io/',
      code: 'https://github.com/codeception/codeceptjs'
    }

    html_filters.push 'codeceptjs/clean_html', 'codeceptjs/entries', 'title'

    options[:root_title] = 'CodeceptJS'
    options[:title] = false
    options[:skip_links] = ->(filter) { !filter.root_page? }
    options[:skip_patterns] = [/changelog/, /quickstart\z/]

    options[:fix_urls] = -> (url) do
      url.sub! %r{\.html\z}, ''
      url.sub! %r{custom-helpers\z}, 'helpers'
      url
    end

    options[:trailing_slash] = true

    options[:attribution] = <<-HTML
      &copy; 2015 DavertMik &lt;davert@codegyre.com&gt; (http://codegyre.com)<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_npm_version('codeceptjs', opts)
    end
  end
end
