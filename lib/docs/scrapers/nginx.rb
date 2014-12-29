module Docs
  class Nginx < UrlScraper
    self.name = 'nginx'
    self.type = 'nginx'
    self.version = '1.7.9'
    self.base_url = 'http://nginx.org/en/docs/'

    html_filters.push 'nginx/clean_html', 'nginx/entries'

    options[:container] = '#content'

    options[:skip] = %w(
      contributing_changes.html
      dirindex.html
      varindex.html)

    options[:skip_patterns] = [/\/faq\//]

    options[:attribution] = <<-HTML
      &copy; 2002-2014 Igor Sysoev<br>
      &copy; 2011-2014 Nginx, Inc.<br>
      Licensed under the BSD License.
    HTML
  end
end
