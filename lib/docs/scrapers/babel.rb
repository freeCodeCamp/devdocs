module Docs
  class Babel < UrlScraper
    self.type = 'simple'
    self.base_url = 'http://babeljs.io/docs/'
    self.release = '6.26.1'
    self.initial_paths = %w(core-packages/)
    self.links = {
      home: 'https://babeljs.io/',
      code: 'https://github.com/babel/babel'
    }

    html_filters.push 'babel/clean_html', 'babel/entries'

    options[:trailing_slash] = true
    options[:skip] = %w{setup/ editors/ community/videos/}

    options[:attribution] = <<-HTML
      &copy; 2018 Sebastian McKenzie<br>
      Licensed under the MIT License.
    HTML

    stub '' do
      '<div></div>'
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://babeljs.io/docs/en/', opts)
      doc.at_css('a[href="/versions"] > h3').content
    end
  end
end
