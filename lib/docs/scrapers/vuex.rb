module Docs
  class Vuex < UrlScraper
    self.name = 'Vuex'
    self.type = 'simple'

    self.links = {
      home: 'https://vuex.vuejs.org',
      code: 'https://github.com/vuejs/vuex'
    }

    html_filters.push 'vuex/entries', 'vuex/clean_html'

    self.release = '3.0.1'
    self.base_url = 'https://vuex.vuejs.org/'

    options[:skip_patterns] = [
      # Other languages
      /^(zh|ja|ru|kr|fr|ptbr)\//,
    ]

    options[:attribution] = <<-HTML
      &copy; 2015&ndash;2018 Evan You, Vue.js contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
