module Docs
  class Jinja < UrlScraper
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://palletsprojects.com/p/jinja/',
      code: 'https://github.com/pallets/jinja'
    }

    html_filters.push 'jinja/entries', 'sphinx/clean_html'

    options[:container] = '.body > .section'
    options[:skip] = %w(integration/ switching/ faq/ changelog/ search/ genindex/)

    options[:attribution] = <<-HTML
      &copy; 2007&ndash;2020 Pallets<br>
      Licensed under the BSD 3-clause License.
    HTML

    version '2.11' do
      self.release = '2.11.x'
      self.base_url = "https://jinja.palletsprojects.com/en/#{self.release}/"
    end

    version '2.10' do
      self.release = '2.10.x'
      self.base_url = "https://jinja.palletsprojects.com/en/#{self.release}/"
    end

    version '2.9' do
      self.release = '2.9.x'
      self.base_url = "https://jinja.palletsprojects.com/en/#{self.release}/"
    end

    def get_latest_version(opts)
      get_latest_github_release('pallets', 'jinja', opts)
    end
  end
end
