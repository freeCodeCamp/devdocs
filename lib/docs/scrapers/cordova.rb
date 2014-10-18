module Docs
  class Cordova < UrlScraper
    self.name = 'Cordova'
    self.type = 'cordova'
    self.version = '4.0.0'
    self.base_url = 'http://cordova.apache.org/docs/en/4.0.0/'
    self.root_path = 'index.html'

    html_filters.push 'cordova/clean_html', 'cordova/entries', 'title'

    options[:container] = ->(filter) { filter.root_page? ? '#home' : '#content' }
    options[:title] = false
    options[:root_title] = 'Apache Cordova'
    options[:skip] = %w(_index.html guide_support_index.md.html)

    options[:attribution] = <<-HTML
      &copy; 2012-2014 The Apache Software Foundation<br>
      Licensed under the Apache License 2.0.
    HTML
  end
end
