module Docs
  class Man < UrlScraper
    self.name = 'Debian man pages'
    self.slug = 'man'
    self.type = 'man'
    self.base_url = 'https://manpages.debian.org/testing/'
    self.links = {
      home: 'https://manpages.debian.org/',
      code: 'https://github.com/Debian/debiman/'
    }

    html_filters.push 'man/entries', 'man/clean_html', 'title'

    options[:container] = '#content'
    options[:skip_patterns] = [/src:/, /en.gz$/, /[1-9]$/, /^lib/]

    options[:attribution] = <<-HTML
      Debian Manpages generated using https://github.com/Debian/debiman/
    HTML
  end
end
