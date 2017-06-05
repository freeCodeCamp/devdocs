module Docs
  class Sequel < UrlScraper
    self.slug = 'sequel'
    self.type = 'rdoc'
    self.release = '4.41.0'
    self.base_url = 'http://sequel.jeremyevans.net/rdoc/classes/'
    self.root_path = 'Sequel.html'


    html_filters.push 'sequel/clean_html', 'sequel/entries'
    options[:container] = '#wrapper'

    options[:attribution] = <<-HTML
      Copyright &copy; 2007-2008 Sharon Rosner Copyright © 2008-2016 Jeremy Evans
    HTML
  end
end
