module Docs
  class Yii1 < UrlScraper
    self.name = 'Yii 1'
    self.slug = 'yii1'
    self.type = 'yii'
    self.version = '1.1.16'
    self.base_url = 'http://www.yiiframework.com/doc/api/1.1/'

    html_filters.push 'yii1/clean_html', 'yii1/entries'

    options[:container] = '.grid_9'
    options[:attribution] = <<-HTML
      &copy; 2008&ndash;2015 by Yii Software LLC<br>
      Licensed under the three clause BSD license.
    HTML
  end
end
