module Docs
  class Drupal < UrlScraper
    self.type = 'drupal'
    self.base_url = 'https://api.drupal.org/api/drupal/'
    self.links = {
      home: 'https://www.drupal.org/',
      code: 'https://git.drupalcode.org/project/drupal'
    }

    html_filters.push 'drupal/entries', 'drupal/clean_html', 'title'

    options[:decode_and_clean_paths] = true
    options[:container] = '#page'
    options[:title] = false
    options[:root_title] = 'Drupal'

    options[:skip_link] = ->(link) { link['href'] =~ /[\?&]order/ }

    options[:skip_patterns] = [
      /test/i,
      /_update_[0-9]{4}/,
      /\/group\/updates\-\d/,
      /interface\/implements/,
      /\/(class|interface|trait)\/hierarchy\//,
      /\/(class|interface|trait)\/uses\//,
      /\/(class|interface|trait)\/references\//,
      /\/(class|interface|trait)\/annotations\//,
      /\/function\/calls\//,
      /\/function\/invokes\//,
      /\/function\/overrides\//,
      /\/function\/references\//,
      /\/function\/implementations\//,
      /\/function\/theme_references\//,
      /upgrade/,
      /DRUPAL_ROOT/,
      /constant\/constants/,
      /theme_invokes/
    ]

    options[:attribution] = <<-HTML
      &copy; 2001&ndash;2022 by the original authors<br>
      Licensed under the GNU General Public License, version 2 and later.<br>
      Drupal is a registered trademark of Dries Buytaert.
    HTML

    version '10' do
      self.release = '10.0.0-alpha6'
      self.root_path = '10.0.x'
      self.initial_paths = %w(groups/10.0.x groups/10.0.x?page=1)

      options[:only_patterns] = [
        /\/class\/[^\/]+\/10\.0\.x\z/,
        /\/group\/[^\/]+\/10\.0\.x\z/,
        /\/function\/[^\/]+\/10\.0\.x\z/,
        /\/constant\/[^\/]+\/10\.0\.x\z/,
        /\/interface\/[^\/]+\/10\.0\.x\z/,
        /\/property\/[^\/]+\/10\.0\.x\z/,
        /\/global\/[^\/]+\/10\.0\.x\z/,
        /\/trait\/[^\/]+\/10\.0\.x\z/,
        /modules.*\/10\.0\.x\z/,
        /includes.*\/10\.0\.x\z/,
        /\A[\w\-\.]+\.php\/10\.0\.x\z/
      ]

      options[:skip] = %w(index.php/8.1.x update.php/10.0.x)

      options[:skip_patterns] += [
        /[^\w\-\.].*\.php\/10\.0\.x\z/,
        /\!src\!/,
        /migrate/,
        /Assertion/,
        /listing_page/,
        /update_api/,
        /vendor/,
        /deprecated/,
        /namespace/,
        /\.yml/,
        /Plugin/,
        /\.theme\//
      ]
    end

    version '9' do
      self.release = '9.3.19'
      self.root_path = '9.3.x'
      self.initial_paths = %w(groups/9.3.x groups/9.3.x?page=1)

      options[:only_patterns] = [
        /\/class\/[^\/]+\/9\.3\.x\z/,
        /\/group\/[^\/]+\/9\.3\.x\z/,
        /\/function\/[^\/]+\/9\.3\.x\z/,
        /\/constant\/[^\/]+\/9\.3\.x\z/,
        /\/interface\/[^\/]+\/9\.3\.x\z/,
        /\/property\/[^\/]+\/9\.3\.x\z/,
        /\/global\/[^\/]+\/9\.3\.x\z/,
        /\/trait\/[^\/]+\/9\.3\.x\z/,
        /modules.*\/9\.3\.x\z/,
        /includes.*\/9\.3\.x\z/,
        /\A[\w\-\.]+\.php\/9\.3\.x\z/
      ]

      options[:skip] = %w(index.php/8.1.x update.php/9.3.x)

      options[:skip_patterns] += [
        /[^\w\-\.].*\.php\/9\.3\.x\z/,
        /\!src\!/,
        /migrate/,
        /Assertion/,
        /listing_page/,
        /update_api/,
        /vendor/,
        /deprecated/,
        /namespace/,
        /\.yml/,
        /Plugin/,
        /\.theme\//
      ]
    end

    version '8' do
      self.release = '8.9.20'
      self.root_path = '8.9.x'
      self.initial_paths = %w(groups/8.9.x groups/8.9.x?page=1)

      options[:only_patterns] = [
        /\/class\/[^\/]+\/8\.9\.x\z/,
        /\/group\/[^\/]+\/8\.9\.x\z/,
        /\/function\/[^\/]+\/8\.9\.x\z/,
        /\/constant\/[^\/]+\/8\.9\.x\z/,
        /\/interface\/[^\/]+\/8\.9\.x\z/,
        /\/property\/[^\/]+\/8\.9\.x\z/,
        /\/global\/[^\/]+\/8\.9\.x\z/,
        /\/trait\/[^\/]+\/8\.9\.x\z/,
        /modules.*\/8\.9\.x\z/,
        /includes.*\/8\.9\.x\z/,
        /\A[\w\-\.]+\.php\/8\.9\.x\z/
      ]

      options[:skip] = %w(index.php/8.9.x update.php/8.9.x)

      options[:skip_patterns] += [
        /[^\w\-\.].*\.php\/8\.9\.x\z/,
        /\!src\!/,
        /migrate/,
        /Assertion/,
        /listing_page/,
        /update_api/,
        /vendor/,
        /deprecated/,
        /namespace/,
        /\.yml/,
        /Plugin/,
        /\.theme\//
      ]
    end

    version '7' do
      self.release = '7.91'
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

    def get_latest_version(opts)
      json = fetch_json('https://packagist.org/packages/drupal/drupal.json', opts)
      json['package']['versions'].keys.find {|version| !version.end_with?('-dev')}
    end
  end
end
