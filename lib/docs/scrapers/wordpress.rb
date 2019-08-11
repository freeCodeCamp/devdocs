module Docs
  class Wordpress < UrlScraper
    self.name = 'WordPress'
    self.type = 'wordpress'
    self.release = '5.2.2'
    self.base_url = 'https://developer.wordpress.org/reference/'
    self.initial_paths = %w(
      functions/
      hooks/
      classes/
    )

    self.links = {
      home: 'https://wordpress.org/',
      code: 'https://github.com/WordPress/WordPress'
    }

    html_filters.push 'wordpress/entries', 'wordpress/clean_html'

    options[:container] = '#content-area'
    options[:trailing_slash] = false
    options[:only_patterns] = [
      /\Afunctions\//,
      /\Ahooks\//,
      /\Aclasses\//
    ]

    options[:skip_patterns] = [
      /\Afunctions\/page\/\d+/,
      /\Ahooks\/page\/\d+/,
      /\Aclasses\/page\/\d+/
    ]

    options[:attribution] = <<-HTML
      &copy; 2003&ndash;2019 WordPress Foundation<br>
      Licensed under the GNU GPLv2+ License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://wordpress.org/download/releases/', opts)
      doc.at_css('.releases.latest td').content
    end
  end
end
