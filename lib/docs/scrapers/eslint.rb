module Docs
  class Eslint < UrlScraper
    self.name = 'ESLint'
    self.type = 'eslint'
    self.release = '4.9.0'
    self.base_url = 'https://eslint.org/'
    self.root_path = 'docs/user-guide/getting-started'

    self.links = {
      home: 'https://eslint.org/',
      code: 'https://github.com/eslint/eslint'
    }

    html_filters.push 'eslint/entries', 'eslint/clean_html'

    options[:container] = 'body'    

    options[:skip_patterns] = [/\Ablog/, /\Ademo/, /\Aparser/, /formatters\//]

    options[:attribution] = <<-HTML
      &copy; Copyright JS Foundation and other contributors, https://js.foundation/<br>
      Licensed under the MIT License.
    HTML
  end
end
