module Docs
  class Axios < UrlScraper
    self.type = 'simple'
    self.links = {
      home: 'hthttps://axios-http.com/',
      code: 'https://github.com/axios/axios'
    }
    self.release = '0.27.2'
    self.base_url = "https://axios-http.com/docs/"
    self.initial_paths = %w(intro)

    html_filters.push 'axios/entries', 'axios/clean_html'

    options[:container] = 'main > .body'

    # https://github.com/axios/axios-docs/blob/master/LICENSE
    options[:attribution] = <<-HTML
      &copy; 2020-present John Jakob "Jake" Sarjeant<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('axios', 'axios', opts)
    end
  end
end
