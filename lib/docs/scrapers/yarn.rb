module Docs
  class Yarn < UrlScraper
    self.type = 'simple'

    options[:root_title] = 'Yarn'
    options[:trailing_slash] = false

    options[:skip] = %w(nightly)

    options[:attribution] = <<-HTML
      &copy; 2016&ndash;present Yarn Contributors<br>
      Licensed under the BSD License.
    HTML

    version 'Berry' do
      self.release = '3.1.1'
      self.base_url = 'https://yarnpkg.com/'
      self.links = {
        home: 'https://yarnpkg.com/',
        code: 'https://github.com/yarnpkg/berry'
      }
      html_filters.push 'yarn/entries_berry', 'yarn/clean_html_berry', 'title'
      options[:skip] = ['features', 'cli', 'configuration', 'advanced']
      options[:skip_patterns] = [/\Aapi/, /\Apackage/]
    end

    version 'Classic' do
      self.release = '1.22.17'
      self.base_url = 'https://classic.yarnpkg.com/en/docs/'
      self.links = {
        home: 'https://classic.yarnpkg.com/',
        code: 'https://github.com/yarnpkg/yarn'
      }
      html_filters.push 'yarn/entries', 'yarn/clean_html', 'title'
      options[:skip_patterns] = [/\Aorg\//]
    end

    def get_latest_version(opts)
      get_latest_github_release('yarnpkg', 'berry', opts)[/[\d.]+/]
    end
  end
end
