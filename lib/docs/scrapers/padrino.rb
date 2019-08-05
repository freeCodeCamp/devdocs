module Docs
  class Padrino < UrlScraper
    self.slug = 'padrino'
    self.type = 'rubydoc'
    self.release = '0.14.4'
    self.base_url = 'https://www.rubydoc.info/github/padrino/padrino-framework/'
    self.root_path = 'file/README.rdoc'
    self.initial_paths = %w(index2)
    self.links = {
      home: 'http://padrinorb.com/',
      code: 'https://github.com/padrino/padrino-framework'
    }

    html_filters.push 'padrino/clean_html', 'padrino/entries'

    options[:container] = ->(filter) { filter.root_page? ? '#filecontents' : '#content' }

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2019 Padrino<br>
      Licensed under the MIT License.
    HTML

    stub 'index2' do
      request_one(url_for('index')).body
    end

    def get_latest_version(opts)
      get_github_tags('padrino', 'padrino-framework', opts)[0]['name']
    end
  end
end
