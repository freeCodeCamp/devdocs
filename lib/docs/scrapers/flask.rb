module Docs
  class Flask < UrlScraper
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://palletsprojects.com/p/flask/',
      code: 'https://github.com/pallets/flask'
    }

    html_filters.push 'flask/entries', 'sphinx/clean_html'

    options[:container] = '.body > .section'
    options[:skip] = %w(extensiondev/ styleguide/ upgrading/ changelog/ license/ contributing/)
    options[:skip_patterns] = [/\Atutorial\//]

    options[:attribution] = <<-HTML
      &copy; 2007&ndash;2020 Pallets<br>
      Licensed under the BSD 3-clause License.
    HTML

    version '1.1' do
      self.release = '1.1.x'
      self.base_url = "https://flask.palletsprojects.com/en/#{self.release}/"
    end

    version '1.0' do
      self.release = '1.0.x'
      self.base_url = "https://flask.palletsprojects.com/en/#{self.release}/"
    end

    version '0.12' do
      self.release = '0.12.x'
      self.base_url = "https://flask.palletsprojects.com/en/#{self.release}/"
    end

    def get_latest_version(opts)
      get_latest_github_release('pallets', 'flask', opts)
    end
  end
end
