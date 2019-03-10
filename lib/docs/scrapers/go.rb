module Docs
  class Go < UrlScraper
    self.type = 'go'
    self.release = '1.11.2'
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

    options[:fix_urls] = ->(url) do
      url.sub 'https://golang.org/pkg//', 'https://golang.org/pkg/'
    end

    options[:attribution] = <<-HTML
      &copy; Google, Inc.<br>
      Licensed under the Creative Commons Attribution License 3.0.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://golang.org/pkg/', opts)

      footer = doc.at_css('#footer').content
      version = footer.scan(/go([0-9.]+)/)[0][0]
      version = version[0...-1] if version.end_with?('.')

      version
    end

    private

    def parse(response) # Hook here because Nokogori removes whitespace from textareas
      response.body.gsub! %r{<textarea\ class="code"[^>]*>([\W\w]+?)</textarea>}, '<pre class="code">\1</pre>'
      super
    end
  end
end
