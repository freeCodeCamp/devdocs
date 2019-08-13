module Docs
  class VueRouter < UrlScraper
    self.name = 'Vue Router'
    self.slug = 'vue_router'
    self.type = 'simple'
    self.release = '3.1.2'
    self.base_url = 'https://router.vuejs.org/'
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

    def get_latest_version(opts)
      get_latest_github_release('vuejs', 'vue-router', opts)
    end
  end
end
