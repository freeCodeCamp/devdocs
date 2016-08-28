module Docs
  class Mongoose < UrlScraper
    self.name = 'Mongoose'
    self.type = 'mongoose'
    self.release = '4.5.9'
    self.base_url = 'http://mongoosejs.com/docs/'
    self.root_path = 'index.html'
    self.initial_paths = %w(guide.html api.html)
    self.links = {
      home: 'http://mongoosejs.com/',
      code: 'https://github.com/Automattic/mongoose'
    }

    html_filters.push 'mongoose/clean_html', 'mongoose/entries'

    options[:container] = '#content'

    options[:skip] = %w(
      faq.html
      prior.html
      migration.html
      plugins)

    options[:attribution] = <<-HTML
      &copy; 2010 LearnBoost<br>
      Licensed under the MIT License.
    HTML
  end
end
