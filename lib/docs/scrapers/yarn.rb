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

    version do
      self.release = '4.5.1'
      self.base_url = 'https://yarnpkg.com/'
      self.links = {
        home: 'https://yarnpkg.com/',
        code: 'https://github.com/yarnpkg/berry'
      }
      self.root_path = 'getting-started'
      html_filters.push 'yarn/entries_berry', 'yarn/clean_html_berry'
      options[:skip] = ['cli', 'cli/builder', 'cli/pnpify', 'cli/sdks', 'protocols']
      options[:skip_patterns] = [/\Aapi/, /\Ablog/, /\Apackage/, /\Aassets/]
    end

    version '3' do
      self.release = '3.1.1'
      self.base_url = 'https://v3.yarnpkg.com/'
      self.links = {
        home: 'https://v3.yarnpkg.com/',
        code: 'https://github.com/yarnpkg/berry'
      }
      self.root_path = 'getting-started'
      html_filters.push 'yarn/entries_berry', 'yarn/clean_html_berry', 'title'
      options[:skip] = ['features', 'cli', 'configuration', 'advanced']
      options[:skip_patterns] = [/\Aapi/, /\Apackage/]    end

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

    private

    # Some pages contain null bytes and cause the parser to fail
    def parse(response)
      response.body.gsub!(/[\x00\u0000\0]/, '')
      super
    end
  end
end
