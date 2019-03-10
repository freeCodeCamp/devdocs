module Docs
  class JqueryCore < Jquery
    self.name = 'jQuery'
    self.release = '3.3.1'
    self.base_url = 'https://api.jquery.com/'
    self.initial_paths = %w(/index/index)
    self.links = {
      home: 'https://jquery.com/',
      code: 'https://github.com/jquery/jquery'
    }

    html_filters.insert_before 'jquery/clean_html', 'jquery_core/entries'

    options[:root_title] = 'jQuery'

    options[:fix_urls] = ->(url) do
      url.sub! 'http://api.jquery.com/', 'https://api.jquery.com/'
    end

    options[:skip_patterns] += [
      /h\/deferred\.reject/i,
      /Selectors\/odd/i,
      /index/i
    ]

    def get_latest_version(opts)
      get_npm_version('jquery', opts)
    end
  end
end
