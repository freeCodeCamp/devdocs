module Docs
  class Yarn < UrlScraper
    self.type = 'simple'
    self.release = '1.19.0'
    self.base_url = 'https://yarnpkg.com/en/docs/'
    self.links = {
      home: 'https://yarnpkg.com/',
      code: 'https://github.com/yarnpkg/yarn'
    }

    html_filters.push 'yarn/entries', 'yarn/clean_html', 'title'

    options[:root_title] = 'Yarn'
    options[:trailing_slash] = false

    options[:skip] = %w(nightly)
    options[:skip_patterns] = [/\Aorg\//]

    options[:attribution] = <<-HTML
      &copy; 2016&ndash;present Yarn Contributors<br>
      Licensed under the BSD License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('yarnpkg', 'yarn', opts)
    end
  end
end
