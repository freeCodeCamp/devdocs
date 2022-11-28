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
    version 'stable' do
      self.release = 'stable'
      self.base_url = 'https://docs.wagtail.org/en/stable/'
    end

    version 'latest' do
      self.release = 'latest'
      self.base_url = 'https://docs.wagtail.org/en/latest/'
    end

    version '4.0.4' do
      self.release = '4.0.4'
      self.base_url = "https://docs.wagtail.org/en/v#{version}/"
    end

    version '4.0' do
      self.release = '4.0'
      self.base_url = "https://docs.wagtail.org/en/v#{version}/"
    end

    version '3.0.3' do
      self.release = '3.0.3'
      self.base_url = "https://docs.wagtail.org/en/v#{version}/"
    end

    version '2.16.3' do
      self.release = '2.16.3'
      self.base_url = "https://docs.wagtail.org/en/v#{version}/"
    end

    version '2.15.6' do
      self.release = '2.15.6'
      self.base_url = "https://docs.wagtail.org/en/v#{version}/"
    end

    version '2.10.2' do
      self.release = '2.10.2'
      self.base_url = "https://docs.wagtail.org/en/v#{version}/"
    end

    version '2.5.2' do
      self.release = '2.5.2'
      self.base_url = "https://docs.wagtail.org/en/v#{version}/"
    end

    version '2.4' do
      self.release = '2.4'
      self.base_url = "https://docs.wagtail.org/en/v#{version}/"
    end

    version '2.3' do
      self.release = '2.3'
      self.base_url = "https://docs.wagtail.org/en/v#{version}/"
    end

    version '2.0.2' do
      self.release = '2.0.2'
      self.base_url = "https://docs.wagtail.org/en/v#{version}/"
    end

    version '1.2' do
      self.release = '1.2'
      self.base_url = "https://docs.wagtail.org/en/v#{version}/"
    end

    version '1.1' do
      self.release = '1.1'
      self.base_url = "https://docs.wagtail.org/en/v#{version}/"
    end

    # this method will fetch the latest version of wagtail
    def get_latest_version(opts)
      get_latest_github_release('wagtail', 'wagtail', opts)
    end
  end
end
