module Docs
  class Markdown < UrlScraper
    self.name = 'Markdown'
    self.type = 'simple'
    self.release = '1.0.1'
    self.base_url = 'https://daringfireball.net/projects/markdown/syntax'

    html_filters.push 'markdown/clean_html', 'markdown/entries'

    options[:container] = '.article'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2004 John Gruber<br>
      Licensed under the BSD License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('http://daringfireball.net/projects/markdown', opts)
      doc.at_css('.article p a').content.scan(/\d\.\d*\.*\d*\.*\d*\.*/)[0]
    end
  end
end
