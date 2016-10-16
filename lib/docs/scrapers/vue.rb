module Docs
  class Vue < UrlScraper
    self.name = 'Vue.js'
    self.slug = 'vue'
    self.type = 'vue'
    self.root_path = '/guide/index.html'
    self.initial_paths = %w(/api/index.html)
    self.links = {
      home: 'https://vuejs.org/',
      code: 'https://github.com/vuejs/vue'
    }

    html_filters.push 'vue/clean_html', 'vue/entries'

    options[:only_patterns] = [/\/guide\//, /\/api\//]

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;2016 Evan You, Vue.js contributors<br>
      Licensed under the MIT License.
    HTML

    version '2' do
      self.release = '2.0.3'
      self.base_url = 'https://vuejs.org'
    end

    version '1' do
      self.release = '1.0.28'
      self.base_url = 'https://v1.vuejs.org'
    end
  end
end
