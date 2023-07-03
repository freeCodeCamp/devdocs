module Docs
  class Vitest < UrlScraper
    self.name = 'Vitest'
    self.slug = 'vitest'
    self.type = 'simple'
    self.links = {
      home: 'https://vitest.dev/',
      code: 'https://github.com/vitest-dev/vitest'
    }

    options[:root_title] = 'Vitest'

    options[:attribution] = <<-HTML
      &copy; 2021-Present Anthony Fu<br>
      &copy; 2021-Present Matias Capeletto<br>
      Licensed under the MIT License.
    HTML

    self.release = '0.32.4'
    self.base_url = 'https://vitest.dev/'
    self.initial_paths = %w(guide/)
    html_filters.push 'vitest/entries', 'vite/clean_html'

    def get_latest_version(opts)
      get_npm_version('vitest', opts)
    end
  end
end
