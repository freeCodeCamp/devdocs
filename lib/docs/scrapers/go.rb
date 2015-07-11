module Docs
  class Go < UrlScraper
    self.type = 'go'
    self.version = '1.4.2'
    self.base_url = 'https://golang.org/pkg/'
    self.links = {
      home: 'https://golang.org/',
      code: 'https://go.googlesource.com/go'
    }

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
