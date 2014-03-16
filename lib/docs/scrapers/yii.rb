module Docs
  class Yii < UrlScraper
    self.name = 'Yii'
    self.slug = 'yii'
    self.type = 'yii'
    self.version = '1.1.14'
    self.base_url = 'http://www.yiiframework.com/doc/api/1.1/'

    html_filters.push 'yii/clean_html', 'yii/entries'

  end
end
