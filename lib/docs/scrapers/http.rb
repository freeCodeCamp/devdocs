module Docs
  class Http < UrlScraper
    self.name = 'HTTP'
    self.type = 'rfc'
    self.base_url = 'http://www.w3.org/Protocols/rfc2616/'
    self.root_path = 'rfc2616.html'

    html_filters.push 'http/clean_html', 'http/entries'

    options[:only] = %w(rfc2616-sec10.html rfc2616-sec14.html)
    options[:container] = ->(filter) { '.toc' if filter.root_page? }
    options[:attribution] = "&copy; 1999 The Internet Society"
  end
end
