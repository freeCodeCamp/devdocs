module Docs
  class Markdown < UrlScraper
    self.name = 'Markdown'
    self.type = 'simple'
    self.base_url = 'http://daringfireball.net/projects/markdown/syntax'

    html_filters.push 'markdown/clean_html', 'markdown/entries'

    options[:container] = '.article'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2004 John Gruber<br>
      Licensed under the BSD License.
    HTML
  end
end
