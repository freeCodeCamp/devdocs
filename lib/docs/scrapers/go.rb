module Docs
  class Go < UrlScraper
    self.type = 'go'
    self.release = '1.17.2'
    self.base_url = 'https://golang.org/pkg/'
    self.links = {
      home: 'https://golang.org/',
      code: 'https://go.googlesource.com/go'
    }

    # Run godoc locally, since https://golang.org/pkg/ redirects to https://pkg.go.dev/std with rate limiting / scraping protection.

    # curl -LO https://golang.org/dl/go1.17.2.windows-amd64.zip
    # go install golang.org/x/tools/cmd/godoc@latest
    # go/bin/godoc -zip=go1.17.2.windows-amd64.zip -goroot=/go
    self.base_url = 'http://localhost:6060/pkg/'

    html_filters.push 'clean_local_urls'
    html_filters.push 'go/clean_html', 'go/entries'
    text_filters.replace 'attribution', 'go/attribution'

    options[:trailing_slash] = true
    options[:container] = '#page .container'
    options[:skip] = %w(runtime/msan/)
    options[:skip_patterns] = [/\/\//]

    options[:fix_urls] = ->(url) do
      url.sub '/pkg//', '/pkg/'
    end

    options[:attribution] = <<-HTML
      &copy; Google, Inc.<br>
      Licensed under the Creative Commons Attribution License 3.0.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://golang.org/project/', opts)
      doc.at_css('#page ul > li > a').text[3..-1]
    end

    private

    def parse(response) # Hook here because Nokogori removes whitespace from textareas
      response.body.gsub! %r{<textarea\ class="code"[^>]*>([\W\w]+?)</textarea>}, '<pre class="code">\1</pre>'
      super
    end
  end
end
