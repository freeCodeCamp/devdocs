module Docs
  class Nginx < UrlScraper
    self.name = 'nginx'
    self.type = 'nginx'
    self.release = '1.17.2'
    self.base_url = 'https://nginx.org/en/docs/'
    self.links = {
      home: 'https://nginx.org/',
      code: 'https://hg.nginx.org/nginx'
    }

    html_filters.push 'nginx/clean_html', 'nginx/entries'

    options[:container] = '#content'

    options[:skip] = %w(
      contributing_changes.html
      dirindex.html
      varindex.html)

    options[:skip_patterns] = [/\/faq\//]

    options[:attribution] = <<-HTML
      &copy; 2002-2019 Igor Sysoev<br>
      &copy; 2011-2019 Nginx, Inc.<br>
      Licensed under the BSD License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://nginx.org/en/download.html', opts)
      table = doc.at_css('#content > table').inner_html
      table.scan(/nginx-([0-9.]+)</)[0][0]
    end
  end
end
