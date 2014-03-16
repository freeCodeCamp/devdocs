module Docs
  class Yii < UrlScraper
    self.type = 'yii'
    self.version = '1.1.14'
    self.base_url = 'http://www.yiiframework.com/doc/api/1.1/'

    html_filters.push 'yii/clean_html', 'yii/entries'

    options[:container] = '.grid_9'
    options[:attribution] = <<-HTML
      &copy; 2008&ndash;2014 by Yii Software LLC<br>
      Licensed under the three clause BSD license.
    HTML
  end
end
