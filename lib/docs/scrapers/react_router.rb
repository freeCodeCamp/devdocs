module Docs
  class ReactRouter < UrlScraper
    self.name = 'React Router'
    self.slug = 'react_router'
    self.type = 'simple'
    self.release = '6.14.1'
    self.base_url = 'https://reactrouter.com/en/6.14.1/'
    self.initial_paths = %w(start/overview)

    self.links = {
      home: 'https://reactrouter.com/',
      code: 'https://github.com/remix-run/react-router'
    }

    html_filters.push 'react_router/entries', 'react_router/clean_html'

    options[:skip_patterns] = [/upgrading/]

    options[:attribution] = <<-HTML
      &copy; React Training 2015-2019<br>
      &copy; Remix Software 2020-2022<br>
      Licensed under the MIT License (MIT).
    HTML

    def get_latest_version(opts)
      get_npm_version('react-router', opts)
    end
  end
end
