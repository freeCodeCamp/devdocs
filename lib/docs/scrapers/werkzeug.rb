module Docs
  class Werkzeug < UrlScraper
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://palletsprojects.com/p/werkzeug/',
      code: 'https://github.com/pallets/werkzeug'
    }

    html_filters.push 'werkzeug/entries', 'sphinx/clean_html'

    options[:container] = '.body > section'
    options[:skip] = %w(changes/)

    options[:attribution] = <<-HTML
      &copy; 2007 Pallets<br>
      Licensed under the BSD 3-clause License.
    HTML

    version '3.0' do
      self.release = '3.0.x'
      self.base_url = "https://werkzeug.palletsprojects.com/en/#{self.release}/"
    end

    version '2.3' do
      self.release = '2.3.x'
      self.base_url = "https://werkzeug.palletsprojects.com/en/#{self.release}/"
    end

    version '2.2' do
      self.release = '2.2.x'
      self.base_url = "https://werkzeug.palletsprojects.com/en/#{self.release}/"
    end

    version '2.1' do
      self.release = '2.1.x'
      self.base_url = "https://werkzeug.palletsprojects.com/en/#{self.release}/"
    end

    version '2.0' do
      self.release = '2.0.x'
      self.base_url = "https://werkzeug.palletsprojects.com/en/#{self.release}/"
    end

    version '1.0' do
      self.release = '1.0.x'
      self.base_url = "https://werkzeug.palletsprojects.com/en/#{self.release}/"
    end

    version '0.16' do
      self.release = '0.16.x'
      self.base_url = "https://werkzeug.palletsprojects.com/en/#{self.release}/"
    end

    version '0.15' do
      self.release = '0.15.x'
      self.base_url = "https://werkzeug.palletsprojects.com/en/#{self.release}/"
    end

    def get_latest_version(opts)
      get_latest_github_release('pallets', 'werkzeug', opts)
    end
  end
end
