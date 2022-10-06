module Docs
  class Fastapi < UrlScraper
    self.name = 'Fastapi'
    self.type = 'fastapi'
    self.release = '0.85.0'
    self.base_url = 'https://fastapi.tiangolo.com/'
    self.root_path = '/'
    self.links = {
      home: 'https://fastapi.tiangolo.com/',
      code: 'https://github.com/tiangolo/fastapi'
    }

    options[:only_patterns] = [
        /\Afeatures\//, /\Apython-types\//,
        /\Atutorial\//, /\Aadvanced\//, /\Aasync\//,
        /\Adeployment\//, /\Aproject-generation\//
    ]

    html_filters.push 'fastapi/container', 'fastapi/clean_html', 'fastapi/entries'

    options[:attribution] = <<-HTML
      &copy; This project is licensed under the terms of the MIT license.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('tiangolo', 'fastapi', opts)
    end

  end
end
