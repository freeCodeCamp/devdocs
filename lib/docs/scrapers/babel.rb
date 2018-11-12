module Docs
  class Babel < UrlScraper
    self.type = 'simple'

    options[:trailing_slash] = false
    options[:attribution] = <<-HTML
      &copy; 2018 Sebastian McKenzie<br>
      Licensed under the MIT License.
    HTML

    version '7' do
      self.release = '7.1.0'
      self.base_url = 'https://babeljs.io/docs/en/'
      self.root_path = 'index.html'
      self.links = {
        home: 'https://babeljs.io/',
        code: 'https://github.com/babel/babel'
      }


      html_filters.push 'docusaurus/clean_html', 'babel/entries_v7'
    end

    version '6' do
      self.base_url = 'https://old.babeljs.io/docs/'
      self.release = '6.26.1'
      self.initial_paths = %w(core-packages/)
      self.links = {
        home: 'https://old.babeljs.io/',
        code: 'https://github.com/babel/babel'
      }

      options[:skip] = %w{setup editors community/videos}

      html_filters.push 'babel/clean_html_v6', 'babel/entries_v6'

      stub '' do
        '<div></div>'
      end
    end
  end
end
