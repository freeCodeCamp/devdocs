module Docs
  class Wagtail < UrlScraper
    self.name = 'Wagtail'
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://wagtail.org/',
      code: 'https://github.com/wagtail/wagtail'
    }

    # adding filters from lib/docs/filters/wagtail
    html_filters.push 'wagtail/entries', 'sphinx/clean_html', 'wagtail/clean_html'

    # attributions are seen at the bottom of every page(copyright and license etc. details)
    options[:attribution] = <<-HTML
      &copy; 2014-present Torchbox Ltd and individual contributors.<br>
      All rights are reserved.<br>
      Licensed under the BSD License.
    HTML

    # no one wants to see docs about search or release notes
    options[:skip] = %w[search.html]
    options[:skip_patterns] = [
      %r{\Areleases/}
    ]

    # updating release and base_url for different versions
    version do
      self.release = '4.1.1'
      self.base_url = 'https://docs.wagtail.org/en/stable/'
    end

    version '3' do
      self.release = '3.0.3'
      self.base_url = "https://docs.wagtail.org/en/v#{release}/"
    end

    version '2' do
      self.release = '2.16.3'
      self.base_url = "https://docs.wagtail.org/en/v#{release}/"
    end

    # this method will fetch the latest version of wagtail
    def get_latest_version(opts)
      get_latest_github_release('wagtail', 'wagtail', opts)
    end
  end
end
