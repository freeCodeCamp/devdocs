module Docs
  class Sinon < UrlScraper
    self.name = 'Sinon.JS'
    self.slug = 'sinon'
    self.type = 'sinon'
    self.links = {
      home: 'https://sinonjs.org/',
      code: 'https://github.com/sinonjs/sinon'
    }

    html_filters.push 'sinon/clean_html', 'sinon/entries'

    options[:title] = 'Sinon.JS'
    options[:container] = '.content .container'

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2018 Christian Johansen<br>
      Licensed under the BSD License.
    HTML

    version '7' do
      self.release = '7.1.1'
      self.base_url = "https://sinonjs.org/releases/v#{release}/"
    end

    version '6' do
      self.release = '6.3.5'
      self.base_url = "https://sinonjs.org/releases/v#{release}/"
    end

    version '5' do
      self.release = '5.1.0'
      self.base_url = "https://sinonjs.org/releases/v#{release}/"
    end

    version '4' do
      self.release = '4.5.0'
      self.base_url = "https://sinonjs.org/releases/v#{release}/"
    end

    version '3' do
      self.release = '3.3.0'
      self.base_url = "https://sinonjs.org/releases/v#{release}/"
    end

    version '2' do
      self.release = '2.4.1'
      self.base_url = "https://sinonjs.org/releases/v#{release}/"
    end

    version '1' do
      self.release = '1.17.7'
      self.base_url = "https://sinonjs.org/releases/v#{release}/"
    end

    def get_latest_version(opts)
      body = fetch('https://sinonjs.org/', opts)
      body.scan(/\/releases\/v([0-9.]+)/)[0][0]
    end
  end
end
