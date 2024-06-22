module Docs
  class Immutable < UrlScraper
    self.name = 'Immutable.js'
    self.slug = 'immutable'
    self.type = 'simple'
    self.release = '4.2.1'
    self.base_url = "https://immutable-js.com/docs/v#{release}/"
    self.links = {
      home: 'https://immutable-js.com/',
      code: 'https://github.com/facebook/immutable-js'
    }

    html_filters.push 'immutable/clean_html', 'immutable/entries'

    options[:container] = '.docContents'
    options[:root_title] = 'Immutable.js'

    options[:trailing_slash] = true
    options[:fix_urls] = ->(url) do
      url.sub! '/index.html', ''
      url.sub! '/index', ''
      url
    end


    options[:attribution] = <<-HTML
      &copy; 2014–present, Lee Byron and other contributors<br>
      Licensed under the 3-clause BSD License.
    HTML

    def get_latest_version(opts)
      get_npm_version('immutable', opts)
    end
  end
end
