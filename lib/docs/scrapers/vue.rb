module Docs
  class Vue < UrlScraper
    self.name = 'Vue.js'
    self.slug = 'vue'
    self.type = 'vue'
    self.version = '1.0.4'
    self.base_url = 'http://vuejs.org'
    self.root_path = '/guide/index.html'
    self.initial_paths = %w(/api/index.html)
    self.links = {
      home: 'http://vuejs.org/',
      code: 'https://github.com/yyx990803/vue'
    }

    html_filters.push 'vue/clean_html', 'vue/entries'

    options[:only_patterns] = [/\/guide\//, /\/api\//]

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;2015 Evan You, Vue.js contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
