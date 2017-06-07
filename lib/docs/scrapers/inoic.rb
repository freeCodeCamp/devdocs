module Docs
  class Ionic < UrlScraper
    self.name = 'Ionic'
    self.slug = 'ionic'
    self.type = 'ionic'
    self.base_url = 'http://ionicframework.com/docs/v2'
    self.links = {
      home: 'https://ionic.io/',
      code: 'https://github.com/driftyco/ionic'
    }

    html_filters.push 'ionic/clean_html', 'ionic/entries', 'title'

    options[:root_title] = 'Ionic'
    options[:only_patterns] = [/reference\//, /api\//]
    options[:skip_patterns] = [/api\/index/]

    options[:attribution] = <<-HTML
      Ionic is licensed under the MIT Open Source license. For more information, see the LICENSE file in this repository.
    HTML
  end
end
