module Docs
  class Codeigniter < UrlScraper
    self.name = 'CodeIgniter'
    self.type = 'codeigniter'
    self.release = '3.0'
    self.base_url = 'http://www.codeigniter.com/user_guide/'
    self.root_path = 'index.html'
    self.links = {
      home: 'http://codeigniter.com/',
      code: 'https://github.com/bcit-ci/CodeIgniter'
    }

    html_filters.push 'codeigniter/clean_html', 'codeigniter/entries'

    options[:container] = '.document'

    options[:only_patterns] = [
      /\Ageneral/,
      /\Alibraries/,
      /\Adatabase/,
      /\Ahelpers/
    ]

    options[:skip] = %w(
      general/welcome.html
      general/requirements.html
      general/credits.html
    )

    options[:attribution] = <<-HTML
      &copy; British Columbia Institute of Technology<br>
      Licensed under the MIT License.
    HTML
  end
end
