module Docs
  class Eslint < UrlScraper
    self.name = 'ESLint'
    self.type = 'simple'
    self.release = '9.25.0'
    self.base_url = 'https://eslint.org/docs/latest/'
    self.root_path = '/'
    self.links = {
      home: 'https://eslint.org/',
      code: 'https://github.com/eslint/eslint'
    }

    html_filters.push 'eslint/entries', 'eslint/clean_html'

    options[:skip_patterns] = [/maintain/, /migrating/, /migrate/, /\Aversions/, /rule-deprecation/]
    options[:skip] = %w(about about/ versions)
    # A number of paths have a trailing slash, causing them to be suffixed by "index" during the NormalizePathsFilter
    options[:replace_paths] = {
      'configure/' => 'configure',
      'contribute/' => 'contribute',
      'contribute/architecture/' => 'contribute/architecture',
      'extend/' => 'extend',
      'flags/' => 'flags',
      'integrate/' => 'integrate',
      'rules/' => 'rules',
      'use/' => 'use',
      'use/formatters/' => 'use/formatters',
      'use/configure/' => 'use/configure',
      'use/configure/rules/' => 'use/configure/rules',
      'use/core-concepts/' => 'use/core-concepts',
      'use/troubleshooting/' => 'use/troubleshooting',
    }

    options[:attribution] = <<-HTML
      &copy; OpenJS Foundation and other contributors<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_npm_version('eslint', opts)
    end
  end
end
