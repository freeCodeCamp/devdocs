module Docs
  class Vuex < UrlScraper
    self.type = 'simple'
    self.release = '3.1.1'
    self.base_url = 'https://vuex.vuejs.org/'
    self.links = {
      home: 'https://vuex.vuejs.org',
      code: 'https://github.com/vuejs/vuex'
    }

    html_filters.push 'vuex/entries', 'vuex/clean_html'

    options[:skip_patterns] = [
      # Other languages
      /^(zh|ja|ru|kr|fr|ptbr)\//,
    ]

    options[:attribution] = <<-HTML
      &copy; 2015&ndash;present Evan You<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_npm_version('vuex', opts)
    end
  end
end
