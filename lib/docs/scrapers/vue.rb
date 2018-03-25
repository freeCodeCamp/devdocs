module Docs
  class Vue < UrlScraper
    self.name = 'Vue.js'
    self.slug = 'vue'
    self.type = 'vue'
    self.links = {
      home: 'https://vuejs.org/',
      code: 'https://github.com/vuejs/vue'
    }

    html_filters.push 'vue/entries', 'vue/clean_html'

    options[:only_patterns] = [/guide\//, /api\//]
    options[:skip] = %w(guide/team.html)
    options[:replace_paths] = { 'guide/' => 'guide/index.html' }

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;2017 Evan You, Vue.js contributors<br>
      Licensed under the MIT License.
    HTML

    version '2' do
      self.release = '2.5.13'
      self.base_url = 'https://vuejs.org/v2/'
      self.root_path = 'guide/index.html'
      self.initial_paths = %w(api/)
    end

    version '1' do
      self.release = '1.0.28'
      self.base_url = 'https://v1.vuejs.org'
      self.root_path = '/guide/index.html'
      self.initial_paths = %w(/api/index.html)
    end
  end
end
