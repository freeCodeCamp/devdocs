
module Docs
  class Vertx < UrlScraper
    self.type = 'vertx'
    self.links = {
      home: 'http://vertx.io',
      code: 'https://github.com/eclipse-vertx/vert.x'
    }

    html_filters.push 'vertx/entries', 'vertx/clean_html'

    self.base_url = 'https://vertx.io/'
    self.root_path = 'docs'
    options[:attribution] = <<-HTML
      by Dor Sahar :)
    HTML

    options[:skip_patterns] = [
      /api/,
      /apidocs/,
      /blog/,
    ]

  end
end
