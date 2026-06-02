module Docs
  class Htmx < UrlScraper
    self.name = 'htmx'
    self.type = 'simple'
    self.slug = 'htmx'
    self.links = {
      home: 'https://htmx.org/',
      code: 'https://github.com/bigskysoftware/htmx'
    }
    self.initial_paths = %w(reference/)

    html_filters.push 'htmx/entries', 'htmx/clean_html'

    options[:trailing_slash] = true
    options[:container] = '.content'
    options[:download_images] = false
    options[:skip_patterns] = [
      /\Aessays/,
      /\Aexamples/,
      /\Amigration-guide/,
      /\Aposts/,
    ]

    # https://github.com/bigskysoftware/htmx/blob/master/LICENSE
    options[:attribution] = <<-HTML
    Licensed under the Zero-Clause BSD License.
    HTML

    version do
      self.release = '2.0.7'
      self.base_url = "https://htmx.org/"
    end

    version '1' do
      self.release = '1.9.12'
      self.base_url = "https://v1.htmx.org/"
    end

    def get_latest_version(opts)
      get_npm_version('htmx.org', opts)
    end
  end
end
