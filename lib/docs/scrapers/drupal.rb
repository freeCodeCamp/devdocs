module Docs
  class Drupal < UrlScraper
    self.name = 'Drupal'
    self.type = 'drupal'
    self.version = '7.37'
    self.base_url = 'https://api.drupal.org/api/drupal/'
    self.initial_paths = %w(
      groups
      groups?page=1)

    html_filters.replace 'normalize_paths', 'drupal/normalize_paths'
    html_filters.replace 'internal_urls', 'drupal/internal_urls'

    html_filters.push 'drupal/entries', 'drupal/clean_html', 'title'

    options[:container] = '#page'
    options[:title] = false
    options[:root_title] = 'Drupal - Open Source CMS | Drupal.org'

    options[:only_patterns] = [
      /\/group\/[^\/]+/,
      /\/function\/[^\/]+/]

    options[:skip_link] = ->(link) {
      begin
        return unless q = URL.parse(link['href']).query
        Hash[URI.decode_www_form(q)].has_key? "order"
      rescue URI::InvalidURIError
        false
      end
    }

    options[:skip] = %w(
      'modules-system-system.install/group/updates-7.x-extra/7',
      'modules-system-system.install/group/updates-6.x-to-7.x/7')

    options[:skip_patterns] = [
      /\/group\/updates\-7/,
      /\/group\/updates\-6/,
      /_update_[0-9]{4}/,               # Skip update functions
      /\/[4-6](\.[0-9])*$/,             # Skip previous versions
      /\/[8-9](\.[0-9])*$/,             # Skip future versions
      /\/function\/calls\//,            # Skip function calls listings
      /\/function\/implementations\//,  # Skip hook implementation listings
      /\.test\/function\//              # Skip test files
    ]

    options[:fix_urls] = ->(url) do
      url.sub! /\/7$/, '' # Remove the version indicator from the current version
      url
    end

    options[:attribution] = <<-HTML
      &copy; 2000&ndash;2015 by the individual contributors.<br>
      Licensed under the Creative Commons License, Attribution-ShareAlike2.0.<br>
      Drupal is a registered trademark of Dries Buytaert.
    HTML

    # Method used at several places to fix special characters at urls from api.drupal.org
    def self.fixUri(path)
      p = path.gsub /%21|!|%2b|%3b|%3a/i, '-' # !+;:
    end

  end
end
