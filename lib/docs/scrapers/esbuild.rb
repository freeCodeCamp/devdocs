module Docs
  class Esbuild < UrlScraper
    self.name = 'esbuild'
    self.slug = 'esbuild'
    self.type = 'simple'
    self.links = {
      home: 'https://esbuild.github.io/',
      code: 'https://github.com/evanw/esbuild'
    }

    options[:container] = 'main'
    options[:root_title] = 'esbuild'

    options[:attribution] = <<-HTML
      &copy; 2020 Evan Wallace<br>
      Licensed under the MIT License.
    HTML

    self.release = '0.18.17'
    self.base_url = 'https://esbuild.github.io/'
    html_filters.push 'esbuild/clean_html', 'esbuild/entries'

    def get_latest_version(opts)
      get_npm_version('esbuild', opts)
    end
  end
end
