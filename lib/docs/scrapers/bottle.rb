module Docs
  class Bottle < UrlScraper
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://bottlepy.org/',
      code: 'https://github.com/bottlepy/bottle'
    }

    html_filters.push 'bottle/entries', 'sphinx/clean_html'

    options[:container] = '.body'

    options[:skip] = %w(changelog.html development.html _modules/bottle.html)

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2017 Marcel Hellkamp<br>
      Licensed under the MIT License.
    HTML

    version '0.12' do
      self.release = '0.12.13'
      self.base_url = "https://bottlepy.org/docs/#{self.version}/"
    end

    version '0.11' do
      self.release = '0.11.7'
      self.base_url = "https://bottlepy.org/docs/#{self.version}/"
    end
  end
end
