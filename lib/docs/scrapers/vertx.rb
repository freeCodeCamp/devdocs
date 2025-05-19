module Docs
  class Vertx < UrlScraper
    self.type = 'vertx'
    self.links = {
      home: 'http://vertx.io',
      code: 'https://github.com/eclipse-vertx/vert.x'
    }

    html_filters.push 'vertx/entries', 'vertx/clean_html'

    options[:attribution] = <<-HTML
      by Dor Sahar :)
    HTML

    options[:skip_patterns] = [
      /api/,
      /5.0.0/,
      /apidocs/,
      /blog/,
    ]

    version '5.0.0' do
      self.release = '5.0.0'
      self.base_url = "https://vertx.io/docs/"
    end

    version '4.5.15' do
      self.release = '4.5.15'
      self.base_url = "https://vertx.io/docs/#{self.version}"
    end

    version '3.9.16' do
      self.release = '4.5.15'
      self.base_url = "https://vertx.io/docs/#{self.version}"
    end
  end
end
