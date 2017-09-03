module Docs
  class Yii < UrlScraper
    self.type = 'yii'

    options[:attribution] = <<-HTML
      &copy; 2008&ndash;2017 by Yii Software LLC<br>
      Licensed under the three clause BSD license.
    HTML

    version '2.0' do
      self.release = '2.0.12'
      self.base_url = 'http://www.yiiframework.com/doc-2.0/'
      self.root_path = 'index.html'
      self.links = {
        home: 'http://www.yiiframework.com/',
        code: 'https://github.com/yiisoft/yii2'
      }

      html_filters.push 'yii/clean_html_v2', 'yii/entries_v2'

      options[:container] = 'div[role=main]'
      options[:skip_patterns] = [/\Ayii-apidoc/]
    end

    version '1.1' do
      self.release = '1.1.19'
      self.base_url = 'http://www.yiiframework.com/doc/api/1.1/'
      self.links = {
        home: 'http://www.yiiframework.com/',
        code: 'https://github.com/yiisoft/yii'
      }

      html_filters.push 'yii/clean_html_v1', 'yii/entries_v1'

      options[:container] = '.grid_9'
    end
  end
end
