module Docs
  class Fastapi < FileScraper
    self.name = 'Fastapi'
    self.type = 'mkdocs'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://fastapi.tiangolo.com/',
      code: 'https://github.com/tiangolo/fastapi'
    }

    html_filters.push 'fastapi/entries', 'mkdocs/clean_html', 'fastapi/clean_html'
    text_filters.push 'fastapi/fix_urls'

    options[:attribution] = <<-HTML
      &copy; This project is licensed under the terms of the MIT license.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('tiangolo', 'fastapi', opts)
    end
  end
end
