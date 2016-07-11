module Docs
  class Drupal < UrlScraper
    self.type = 'drupal'
    self.base_url = 'https://api.drupal.org/api/drupal/'
    self.links = {
      home: 'https://www.drupal.org/',
      code: 'http://cgit.drupalcode.org/drupal'
    }

    html_filters.push 'drupal/entries', 'drupal/clean_html', 'title'

    options[:decode_and_clean_paths] = true
    options[:container] = '#page-inner'
    options[:title] = false
    options[:root_title] = 'Drupal'

    options[:skip_link] = ->(link) { link['href'] =~ /[\?&]order/ }

    options[:skip_patterns] = [
      /\/group\/updates\-\d/,
      /_update_[0-9]{4}/,               # Skip update functions
      /\/class\/hierarchy\//,           # Skip class hierarchy listings
      /\/function\/calls\//,            # Skip function calls listings
      /\/function\/invokes\//,          # Skip function invokations listings
      /\/function\/overrides\//,        # Skip function overrides listings
      /\/function\/references\//,       # Skip function references listings
      /\/function\/implementations\//,  # Skip hook implementation listings
      /\/function\/theme_references\//, # Skip hook references listings
      /\.test\//,                       # Skip test files
      /_test\//,                        # Skip test files
      /\.test\.module\//,               # Skip test files
      /_test\.module\//,                # Skip test files
      /_test_/,                         # Skip test files
      /_test\./,                        # Skip test files
      /tests/,
      /testing/,
      /upgrade/,
      /DRUPAL_ROOT/,
      /simpletest/,
      /constant\/constants/,
      /interface\/implements/,
      /interface\/hierarchy/,
      /theme_invokes/
    ]

    options[:attribution] = <<-HTML
      &copy; 2001&ndash;2016 by the original authors<br>
      Licensed under the GNU General Public License, version 2 and later.<br>
      Drupal is a registered trademark of Dries Buytaert.
    HTML

    version '7' do
      self.release = '7.50'
      self.root_path = '7.x'
      self.initial_paths = %w(groups/7.x groups/7.x?page=1)

      options[:only_patterns] = [
        /\/class\/[^\/]+\/7\.x\z/,
        /\/group\/[^\/]+\/7\.x\z/,
        /\/function\/[^\/]+\/7\.x\z/,
        /\/constant\/[^\/]+\/7\.x\z/,
        /\/interface\/[^\/]+\/7\.x\z/,
        /\/property\/[^\/]+\/7\.x\z/,
        /\/global\/[^\/]+\/7\.x\z/,
        /modules.*\/7\.x\z/,
        /includes.*\/7\.x\z/,
        /\A[\w\-\.]+\.php\/7\.x\z/
      ]
    end
  end
end
