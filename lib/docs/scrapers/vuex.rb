module Docs
  class Vuex < UrlScraper
    self.type = 'simple'
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

    version '4' do
      self.release = '4.0.2'
      self.base_url = 'https://next.vuex.vuejs.org/'
    end

    version '3' do
      self.release = '3.6.2'
      self.base_url = 'https://vuex.vuejs.org/'
    end

    def get_latest_version(opts)
      get_npm_version('vuex', opts, 'next')
    end
  end
end
