module Docs
  class VueRouter < UrlScraper
    self.name = 'Vue Router'
    self.slug = 'vue_router'
    self.type = 'simple'
    self.links = {
      home: 'https://router.vuejs.org',
      code: 'https://github.com/vuejs/vue-router'
    }

    html_filters.push 'vue_router/entries', 'vue_router/clean_html'

    options[:skip_patterns] = [
      # Other languages
      /^(zh|ja|ru|kr|fr)\//,
    ]

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;present Evan You<br>
      Licensed under the MIT License.
    HTML

    version '4' do
      self.release = '4.0.12'
      self.base_url = 'https://next.router.vuejs.org/'
    end

    version '3' do
      self.release = '3.5.1'
      self.base_url = 'https://router.vuejs.org/'
    end

    def get_latest_version(opts)
      get_npm_version('vue-router', opts, 'next')
    end
  end
end
