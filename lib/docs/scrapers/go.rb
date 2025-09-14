module Docs
  class Go < UrlScraper
    self.type = 'go'
    self.release = '1.25.1'
    self.base_url = 'https://golang.org/pkg/'
    self.links = {
      home: 'https://golang.org/',
      code: 'https://go.googlesource.com/go'
    }

    # Run godoc locally, since https://golang.org/pkg/ redirects to https://pkg.go.dev/std with rate limiting / scraping protection.

    # podman run --net host --rm -it docker.io/golang:1.25.1
    #podman# go install golang.org/x/tools/cmd/godoc@latest
    #podman# rm -r /usr/local/go/test/
    #podman# godoc -http 0.0.0.0:6060 -v

    # or using alpine
    # podman run --net host --rm -it alpine:latest
    #podman# apk add curl
    #podman# curl -LO https://go.dev/dl/go1.25.1.linux-amd64.tar.gz
    #podman# tar xf go1.25.1.linux-amd64.tar.gz
    #podman# go/bin/go install golang.org/x/tools/cmd/godoc@latest
    #podman# /root/go/bin/godoc -http 0.0.0.0:6060 -v

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
      doc = fetch_doc('https://go.dev/dl/', opts)
      doc.at_css('.download[href]')['href'][/go1[0-9.]+[0-9]/][2..]
    end

    private

    def parse(response) # Hook here because Nokogori removes whitespace from textareas
      response.body.gsub! %r{<textarea\ class="code"[^>]*>([\W\w]+?)</textarea>}, '<pre class="code">\1</pre>'
      super
    end
  end
end
