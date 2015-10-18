module Docs
  class Drupal < UrlScraper
    self.type = 'drupal'
    self.version = '7.40'
    self.base_url = 'https://api.drupal.org/api/drupal/'
    self.initial_paths = %w(groups groups?page=1)
    self.links = {
      home: 'https://www.drupal.org/'
    }

    html_filters.push 'drupal/entries', 'drupal/clean_html', 'title'

    options[:decode_and_clean_paths] = true
    options[:container] = '#page-inner'
    options[:title] = false
    options[:root_title] = 'Drupal'

    options[:only_patterns] = [
      /\/class\/[^\/]+/,
      /\/group\/[^\/]+/,
      /\/function\/[^\/]+/]

    options[:skip_link] = ->(link) { link['href'] =~ /[\?&]order/ }

    options[:skip_patterns] = [
      /\/group\/updates\-7/,
      /\/group\/updates\-6/,
      /_update_[0-9]{4}/,               # Skip update functions
      /\/[4-6](\.[0-9])*$/,             # Skip previous versions
      /\/[8-9](\.[0-9])*$/,             # Skip future versions
      /\/class\/hierarchy\//,           # Skip class hierarchy listings
      /\/function\/calls\//,            # Skip function calls listings
      /\/function\/invokes\//,          # Skip function invokations listings
      /\/function\/overrides\//,        # Skip function overrides listings
      /\/function\/references\//,       # Skip function references listings
      /\/function\/implementations\//,  # Skip hook implementation listings
      /\/function\/theme_references\//, # Skip hook references listings
      /\.test\/function\//              # Skip test files
    ]

    options[:fix_urls] = ->(url) do
      url.remove! %r{/7$}
      url
    end

    options[:attribution] = <<-HTML
      &copy; 2001&ndash;2015 by the original authors<br>
      Licensed under the GNU General Public License, version 2 and later.<br>
      Drupal is a registered trademark of Dries Buytaert.
    HTML
  end
end
