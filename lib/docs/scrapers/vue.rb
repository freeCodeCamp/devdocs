module Docs
  class Vue < UrlScraper
    self.name = 'Vue.js'
    self.slug = 'vue'
    self.type = 'vue'
    self.version = '0.12.5'
    self.base_url = 'http://vuejs.org/api/'


    html_filters.push 'vue/clean_html', 'vue/entries'
    options[:follow_links] = ->(filter) { filter.root_page? }


    options[:attribution] = <<-HTML
      &copy; 2014&ndash;2015 Evan You, Vue.js contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
