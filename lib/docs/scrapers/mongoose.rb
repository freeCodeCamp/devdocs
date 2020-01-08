module Docs
  class Mongoose < UrlScraper
    self.name = 'Mongoose'
    self.type = 'simple'
    self.release = '5.8.5'
    self.base_url = 'https://mongoosejs.com/docs/'
    self.root_path = 'index.html'
    self.initial_paths = %w(guide.html)
    self.force_gzip = true
    self.links = {
      home: 'http://mongoosejs.com/',
      code: 'https://github.com/Automattic/mongoose'
    }

    html_filters.push 'mongoose/clean_html', 'mongoose/entries'

    options[:container] = '#content'

    options[:skip] = %w(
      api.html
      faq.html
      prior.html
      migration.html
      plugins)

    options[:attribution] = <<-HTML
      &copy; 2010 LearnBoost<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://mongoosejs.com/docs/', opts)
      label = doc.at_css('.pure-menu-link').content.strip
      label.sub(/Version /, '')
    end
  end
end
