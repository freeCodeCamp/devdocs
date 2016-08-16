module Docs
  class Bottle < FileScraper
    self.type = 'sphinx'
    self.dir = ""
    self.root_path = "index.html"
    self.links = {
      home: 'https://bottle.org/',
      code: 'https://github.com/bottlepy/bottle'
    }

    html_filters.push 'bottle/entries', 'sphinx/clean_html'

    options[:container] = '.body'

    options[:skip] = %w(
      changelog.html
      development.html
      plugindev.html
      _modules/bottle.html
    )

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2016, Marcel Hellkamp<br>
      Licensed under the MIT License.<br>
    HTML

    version '0.12' do # http://bottlepy.org/docs/0.12/bottle-docs.zip
      self.release = '0.12'
      self.base_url = "http://bottlepy.org/docs/#{self.version}/"
    end

    version '0.11' do # http://bottlepy.org/docs/0.11/bottle-docs.zip
      self.release = '0.11'
      self.base_url = "http://bottlepy.org/docs/#{self.version}/"
    end
  end
end
