module Docs
  class Composer < UrlScraper
    self.type = 'simple'
    self.release = '1.9.0'
    self.base_url = 'https://getcomposer.org/doc/'
    self.links = {
      home: 'https://getcomposer.org',
      code: 'https://github.com/composer/composer'
    }

    html_filters.push 'composer/clean_html', 'composer/entries'

    options[:container] = '#main'

    options[:skip_patterns] = [
      /^faqs/
    ]

    options[:attribution] = <<-HTML
      &copy; Nils Adermann, Jordi Boggiano<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('composer', 'composer', opts)
    end
  end
end
