module Docs
  class D < UrlScraper
    self.release = '2.075.1'
    self.type = 'd'
    self.base_url = 'http://dlang.org/phobos/'

    html_filters.push 'd/entries', 'd/clean_html'

    options[:container] = '#content'
    options[:title] = false
    options[:root_title] = 'D Language'
    options[:skip_patterns] = [/#.*/]

    options[:attribution] = <<-HTML
      Copyright &copy; 1999-2017 by the D Language Foundation
    HTML
  end
end
