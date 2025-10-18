module Docs
  class Lit < UrlScraper
    self.name = 'Lit'
    self.slug = 'lit'
    self.type = 'lit'

    self.links = {
      home: 'https://lit.dev/',
      code: 'https://github.com/lit/lit/'
    }

    options[:container] = 'main'

    options[:max_image_size] = 250_000

    # Note: the copyright will change soon due to https://lit.dev/blog/2025-10-14-openjs/
    options[:attribution] = <<-HTML
      &copy; Google LLC<br>
      Licensed under the Creative Commons Attribution 3.0 Unported License.
    HTML

    options[:fix_urls] = ->(url) do
      # A name without any extension is assumed to be a directory.
      # example.com/foobar -> example.com/foobar/
      url.sub! /(\/[-a-z0-9]+)([#?]|$)/i, '\1/\2'

      url
    end

    # The order of the filters is important.
    # The entries filter is applied to the raw (mostly) unmodified HTML.
    # The clean_html filter reformats the HTML to the a more appropriate markup for devdocs.
    html_filters.push 'lit/entries', 'lit/clean_html'

    version '3' do
      self.release = '3.3.1'
      self.base_url = 'https://lit.dev/docs/'
      options[:skip_patterns] = [/v\d+\//]
    end

    version '2' do
      self.release = '2.8.0'
      self.base_url = 'https://lit.dev/docs/v2/'
    end

    version '1' do
      self.release = '1.0.1'
      self.base_url = 'https://lit.dev/docs/v1/'
    end

    def get_latest_version(opts)
      get_npm_version('lit', opts)
    end
  end
end
