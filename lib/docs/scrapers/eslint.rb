module Docs
  class Eslint < UrlScraper
    self.name = 'ESLint'
    self.type = 'simple'
    self.release = '6.8.0'
    self.base_url = 'https://eslint.org/docs/'
    self.root_path = 'user-guide/getting-started'
    self.links = {
      home: 'https://eslint.org/',
      code: 'https://github.com/eslint/eslint'
    }

    html_filters.push 'eslint/entries', 'eslint/clean_html'

    options[:skip_patterns] = [/maintainer-guide/]
    options[:skip] = %w(about about/ rules)
    options[:replace_paths] = { 'user-guide' => 'user-guide/' }

    options[:attribution] = <<-HTML
      &copy; JS Foundation and other contributors<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_npm_version('eslint', opts)
    end
  end
end
