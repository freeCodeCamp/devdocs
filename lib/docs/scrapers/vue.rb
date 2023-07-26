module Docs
  class Vue < UrlScraper
    self.name = 'Vue'
    self.slug = 'vue'
    self.type = 'vue'
    self.links = {
      home: 'https://vuejs.org/',
      code: 'https://github.com/vuejs/core'
    }

    options[:only_patterns] = [/^$/ ,/guide\//, /api\//]
    options[:skip] = %w(guide/team.html)
    options[:skip_patterns] = [/guide\/contributing/]
    options[:replace_paths] = { 'guide/' => 'guide/index.html' }

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;present Yuxi Evan You<br>
      Licensed under the MIT License.
    HTML

    version '3' do
      self.release = '3.3.4'
      self.base_url = 'https://vuejs.org/'
      self.initial_paths = %w(guide/introduction.html)
      html_filters.push 'vue/entries_v3', 'vue/clean_html'
    end

    version '2' do
      self.release = '2.7.14'
      self.base_url = 'https://v2.vuejs.org/v2/'
      self.initial_paths = %w(api/)
      self.root_path = 'guide/'
      html_filters.push 'vue/entries', 'vue/clean_html'
    end

    version '1' do
      self.release = '1.0.28'
      self.base_url = 'https://v1.vuejs.org'
      self.initial_paths = %w(/api/index.html)
      html_filters.push 'vue/entries', 'vue/clean_html'
    end

    def get_latest_version(opts)
      get_npm_version('vue', opts)
    end
  end
end
