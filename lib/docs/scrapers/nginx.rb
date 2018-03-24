module Docs
  class Nginx < UrlScraper
    self.name = 'nginx'
    self.type = 'nginx'
    self.release = '1.13.10'
    self.base_url = 'https://nginx.org/en/docs/'
    self.links = {
      home: 'https://nginx.org/',
      code: 'http://hg.nginx.org/nginx'
    }

    html_filters.push 'nginx/clean_html', 'nginx/entries'

    options[:container] = '#content'

    options[:skip] = %w(
      contributing_changes.html
      dirindex.html
      varindex.html)

    options[:skip_patterns] = [/\/faq\//]

    options[:attribution] = <<-HTML
      &copy; 2002-2018 Igor Sysoev<br>
      &copy; 2011-2018 Nginx, Inc.<br>
      Licensed under the BSD License.
    HTML
  end
end
