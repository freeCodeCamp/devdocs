module Docs
  class Babel < UrlScraper
    self.type = 'simple'
    self.base_url = 'https://babeljs.io/docs/'
    self.links = {
      home: 'https://babeljs.io/',
      code: 'https://github.com/babel/babel'
    }

    html_filters.push 'babel/clean_html', 'babel/entries'

    options[:trailing_slash] = true

    options[:skip_patterns] = [
      /usage/,
      /configuration/,
      /learn/,
      /v7-migration/,
      /v7-migration-api/,
      /editors/,
      /presets/,
      /caveats/,
      /faq/,
      /roadmap/
    ]

    options[:skip_link] = ->(link) {
       link['href'].include?('https://babeljs.io/docs/en/')
    }

    options[:attribution] = <<-HTML
      &copy; 2014-present Sebastian McKenzie<br>
      Licensed under the MIT License.
    HTML

    version '7' do
      self.release = '7.21.4'
    end

    version '6' do
      self.release = '6.26.1'
    end

    def get_latest_version(opts)
      get_latest_github_release('babel', 'babel', opts)
    end

  end
end
