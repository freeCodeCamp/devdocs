module Docs
  class Selenium < UrlScraper
    self.name = 'Selenium'
    self.type = 'selenium'
    self.slug = 'selenium'
    self.version = '1.0.1'
    self.base_url = 'http://release.seleniumhq.org/selenium-core/1.0.1/reference.html'

    html_filters.push 'selenium/entries', 'selenium/clean_html', 'title'

    options[:skip_links] = true
    options[:title] = self.name

    options[:attribution] = <<-HTML
      &copy; 2006&ndash;2014 Selenium Project 
      Licensed under the Apache 2.0 License
    HTML
  end
end
