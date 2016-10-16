module Docs
  class Angular < UrlScraper
    self.type = 'angular'
    self.root_path = 'api/'
    self.links = {
      home: 'https://angular.io/',
      code: 'https://github.com/angular/angular'
    }

    html_filters.push 'angular/entries', 'angular/clean_html'

    options[:skip_patterns] = [/deprecated/]
    options[:skip] = %w(
      index.html
      styleguide.html
      quickstart.html
      guide/cheatsheet.html
      guide/style-guide.html)

    options[:replace_paths] = {
      'testing/index.html'  => 'guide/testing.html',
      'guide/glossary.html' => 'glossary.html',
      'tutorial'            => 'tutorial/'
    }

    options[:fix_urls] = -> (url) do
      url.sub! %r{\A(https://angular\.io/docs/.+/)index\.html\z}, '\1'
      url.sub! %r{\A(https://angular\.io/docs/.+/index)/\z}, '\1'
      url
    end

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2016 Google, Inc.<br>
      Licensed under the Creative Commons Attribution License 4.0.
    HTML

    stub 'api/' do
      capybara = load_capybara_selenium
      capybara.app_host = 'https://angular.io'
      capybara.visit('/docs/ts/latest/api/')
      capybara.execute_script('return document.body.innerHTML')
    end

    version '2 TypeScript' do
      self.release = '2.1.0'
      self.base_url = 'https://angular.io/docs/ts/latest/'
    end

    private

    def parse(string)
      string.gsub! '<code-example', '<pre'
      string.gsub! '</code-example', '</pre'
      string.gsub! '<code-pane', '<pre'
      string.gsub! '</code-pane', '</pre'
      string.gsub! '<live-example></live-example>', 'live example'
      string.gsub! '<live-example', '<span'
      string.gsub! '</live-example', '</span'
      super string
    end
  end
end
