module Docs
  class Go < UrlScraper
    self.type = 'go'
    self.release = '1.10.0'
    self.base_url = 'https://golang.org/pkg/'
    self.links = {
      home: 'https://golang.org/',
      code: 'https://go.googlesource.com/go'
    }

    html_filters.push 'go/clean_html', 'go/entries'

    options[:trailing_slash] = true
    options[:container] = '#page .container'
    options[:skip] = %w(runtime/msan/)
    options[:skip_patterns] = [/\/\//]

    options[:attribution] = <<-HTML
      &copy; Google, Inc.<br>
      Licensed under the Creative Commons Attribution License 3.0.
    HTML

    private

    def parse(response) # Hook here because Nokogori removes whitespace from textareas
      response.body.gsub! %r{<textarea\ class="code"[^>]*>([\W\w]+?)</textarea>}, '<pre class="code">\1</pre>'
      super
    end
  end
end
