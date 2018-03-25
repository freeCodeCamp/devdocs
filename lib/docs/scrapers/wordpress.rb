module Docs
  class Wordpress < UrlScraper
    self.name = 'WordPress'
    self.type = 'wordpress'
    self.release = '4.9.4'
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

    html_filters.push 'wordpress/clean_html', 'wordpress/entries'

    options[:container] = '#content-area'
    options[:trailing_slash] = true
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
      &copy; 2003&ndash;2018 WordPress Foundation<br>
      Licensed under the GNU GPLv2+ License.
    HTML
  end
end