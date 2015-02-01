module Docs
  class Go < UrlScraper
    self.type = 'go'
    self.version = '1.4.1'
    self.base_url = 'http://golang.org/pkg/'

    html_filters.push 'go/clean_html', 'go/entries'

    options[:container] = '#page .container'

    options[:attribution] = <<-HTML
      &copy; Google, Inc.<br>
      Licensed under the Creative Commons Attribution License 3.0.
    HTML

    private

    def parse(html) # Hook here because Nokogori removes whitespace from textareas
      super html.gsub %r{<textarea\ class="code"[^>]*>([\W\w]+?)</textarea>}, '<pre class="code">\1</pre>'
    end
  end
end
