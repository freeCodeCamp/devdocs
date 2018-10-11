module Docs
  class VueRouter < UrlScraper
    self.slug = 'vue_router'
    self.name = 'Vue Router'
    self.type = 'simple'

    self.links = {
      home: 'https://router.vuejs.org',
      code: 'https://github.com/vuejs/vue-router'
    }

    html_filters.push 'vue_router/entries', 'vue_router/clean_html'

    self.release = '3.0.1'
    self.base_url = 'https://router.vuejs.org/'

    options[:skip_patterns] = [
      # Other languages
      /^(zh|ja|ru|kr|fr)\//,
    ]

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;2018 Evan You, Vue.js contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
