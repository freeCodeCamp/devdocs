module Docs
  class Requests < UrlScraper
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://requests.readthedocs.io/',
      code: 'https://github.com/psf/requests'
    }
    self.release = '2.28.1'
    self.base_url = "https://requests.readthedocs.io/en/latest/api/"

    html_filters.push 'requests/entries', 'sphinx/clean_html'

    options[:container] = '.body > section'

    options[:attribution] = <<-HTML
      &copy; 2011-2022 Kenneth Reitz and other contributors<br>
      Licensed under the Apache license.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('psf', 'requests', opts)
    end
  end
end
