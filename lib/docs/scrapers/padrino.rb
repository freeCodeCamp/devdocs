module Docs
  class Padrino < UrlScraper
    self.name = 'padrino'
    self.slug = 'padrino'
    self.type = 'ruby'
    self.version = 'master'
    self.base_url = 'http://www.rubydoc.info/github/padrino/padrino-framework'
    self.links = {
      home: 'http://padrinorb.com/',
      code: 'https://github.com/padrino/padrino-framework'
    }

    html_filters.push 'padrino/clean_html', 'padrino/entries'

    options[:attribution] = <<-HTML
                  &copy; Padrino contributors<br>
                        Licensed under the Creative Commons Attribution License.
    HTML
  end
end
