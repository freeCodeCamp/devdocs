module Docs
  class Ramda < UrlScraper
    self.type = 'ramda'
    self.links = {
      home: 'http://ramdajs.com/',
      code: 'https://github.com/ramda/ramda/'
    }

    html_filters.push 'ramda/entries', 'ramda/clean_html', 'title'

    options[:title] = 'Ramda'
    options[:attribution] = <<-HTML
      &copy; 2013&ndash;2024 Scott Sauyet and Michael Hurley<br>
      Licensed under the MIT License.
    HTML

    version '0.30' do
      self.release = '0.30.1'
      self.base_url = "https://ramdajs.com/#{release}/docs/"
    end

    version '0.29' do
      self.release = '0.29.1'
      self.base_url = "https://ramdajs.com/#{release}/docs/"
    end

    def get_latest_version(opts)
      get_npm_version('ramda', opts)
    end
  end
end
