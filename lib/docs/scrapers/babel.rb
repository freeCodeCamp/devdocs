module Docs
  class Babel < UrlScraper
    self.type = 'babel'
    self.base_url = 'http://babeljs.io/docs/'
    self.root_path = '/plugins/'
    self.release = '6.26.0'
    self.initial_paths = %w[faq tour usage/babel-register core-packages editors usage/caveats]
    self.links = {
      home: 'https://babeljs.io/',
      code: 'https://github.com/babel/babel'
    }

    html_filters.push 'babel/clean_html', 'babel/entries'

    options[:trailing_slash] = true
    options[:container] = '.docs-content'
    options[:skip] = %w{setup/ community/videos/}
    options[:fix_urls] = ->(url) do
      return url unless url.start_with? self.base_url
      url.sub %r{/(index\.\w+)?$}, ''
    end

    options[:attribution] = <<-HTML
      &copy; 2018 Sebastian McKenzie<br>
      Licensed under the
      <a href="https://github.com/babel/website/blob/master/LICENSE">
        MIT License
      </a>
    HTML
  end
end
