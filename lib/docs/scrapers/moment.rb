module Docs
  class Moment < UrlScraper
    self.name = 'Moment.js'
    self.slug = 'moment'
    self.type = 'moment'
    self.release = '2.21.0'
    self.base_url = 'http://momentjs.com'
    self.root_path = '/docs/'
    self.initial_paths = %w(/guides/)
    self.links = {
      home: 'http://momentjs.com/',
      code: 'https://github.com/moment/moment/'
    }

    html_filters.push 'moment/clean_html', 'moment/entries', 'title'

    options[:title] = 'Moment.js'
    options[:container] = '.docs-content'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; JS Foundation and other contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
