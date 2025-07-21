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
    options[:download_images] = false
    options[:skip] = %w(blog)

    options[:attribution] = <<-HTML
      &copy; 2021-Present Anthony Fu<br>
      &copy; 2021-Present Matias Capeletto<br>
      Licensed under the MIT License.
    HTML

    self.initial_paths = %w(guide/)
    html_filters.push 'vitest/entries', 'vite/clean_html'
    
    version do
      self.release = '3.0.8'
      self.base_url = 'https://vitest.dev/'
    end
    
    version '2' do
      self.release = '2.1.9'
      self.base_url = 'https://v2.vitest.dev/'
    end

    def get_latest_version(opts)
      get_npm_version('vitest', opts)
    end
  end
end
