module Docs
  class Drupal < UrlScraper
    self.name = 'Drupal'
    self.type = 'drupal'
    self.version = '7.36'
    self.base_url = 'https://api.drupal.org/api/drupal'
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
      /\/group\/[^\/]+\/7/,
      /\/function\/[^\/]+\/7/]

    options[:skip_link] = ->(link) {
      begin
        return unless q = URL.parse(link['href']).query
        Hash[URI.decode_www_form(q)].has_key? "order"
      rescue URI::InvalidURIError
        false
      end
    }

    options[:attribution] = <<-HTML
      &copy; 2000&ndash;2015 by the individual contributors.<br>
      Licensed under the Creative Commons License, Attribution-ShareAlike2.0.<br>
      Drupal is a registered trademark of Dries Buytaert.
    HTML

    # Method used at several places to fix special characters at urls from api.drupal.org
    def self.fixUri(path)
      p = path.gsub /%21|!|%2b|%3b|%3a/i, '-' # !+;:
      p.gsub! /\./, '_' # dots
      p.gsub /__/, '..' # revert doble dots to prevent breaking relative urls
    end

  end
end
