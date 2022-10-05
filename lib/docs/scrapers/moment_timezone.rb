module Docs
  class MomentTimezone < UrlScraper
    self.name = 'Moment.js Timezone'
    self.slug = 'moment_timezone'
    self.type = 'moment'
    self.release = '0.5.37'
    self.base_url = 'https://momentjs.com/timezone'
    self.root_path = '/docs/'
    self.initial_paths = %w(/docs/)
    self.links = {
      home: 'https://momentjs.com/timezone/',
      code: 'https://github.com/moment/moment-timezone/'
    }

    html_filters.push 'moment/clean_html', 'moment_timezone/entries', 'title'

    options[:title] = 'Moment.js Timezone'
    options[:container] = '.docs-content'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; JS Foundation and other contributors<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_github_tags('moment', 'moment-timezone', opts)[0]['name']
    end
  end
end
