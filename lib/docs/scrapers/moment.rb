module Docs
  class Moment < UrlScraper
    self.name = 'Moment.js'
    self.slug = 'moment'
    self.type = 'moment'
    self.release = '2.22.1'
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

    def get_latest_version(opts)
      get_github_tags('moment', 'moment', opts)[0]['name']
    end
  end
end
