module Docs
  class Angular < UrlScraper
    self.type = 'angular'
    self.root_path = 'api/'
    self.links = {
      home: 'https://angular.io/',
      code: 'https://github.com/angular/angular'
    }

    html_filters.push 'angular/entries', 'angular/clean_html'

    options[:skip_patterns] = [/deprecated/, /VERSION-let/]
    options[:skip] = %w(
      index.html
      styleguide.html
      quickstart.html
      guide/cheatsheet.html
      guide/style-guide.html)

    options[:replace_paths] = {
      'testing/index.html'  => 'guide/testing.html',
      'guide/glossary.html' => 'glossary.html',
      'tutorial'            => 'tutorial/',
      'api'                 => 'api/'
    }

    options[:fix_urls] = -> (url) do
      url.sub! %r{\A(https://angular\.io/docs/.+/)index\.html\z}, '\1'
      url
    end

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2016 Google, Inc.<br>
      Licensed under the Creative Commons Attribution License 4.0.
    HTML

    stub 'api/' do
      capybara = load_capybara_selenium
      capybara.app_host = 'https://angular.io'
      capybara.visit(URL.parse(self.base_url).path + 'api/')
      capybara.execute_script('return document.body.innerHTML')
    end

    version '2 TypeScript' do
      self.release = '2.4.3'
      self.base_url = 'https://angular.io/docs/ts/latest/'
    end

    version '2 Dart' do
      self.release = '2.2.4'
      self.base_url = 'https://angular.io/docs/dart/latest/'

      options[:skip_patterns] += [/angular2\.compiler/]
      options[:skip_link] = ->(link) do
        link.parent['class'].try(:include?, 'inherited') || link.parent.parent['class'].try(:include?, 'inherited')
      end
    end

    private

    def parse(response)
      response.body.gsub! '<code-example', '<pre'
      response.body.gsub! '</code-example', '</pre'
      response.body.gsub! '<code-pane', '<pre'
      response.body.gsub! '</code-pane', '</pre'
      response.body.gsub! '<live-example></live-example>', 'live example'
      response.body.gsub! '<live-example', '<span'
      response.body.gsub! '</live-example', '</span'
      super
    end
  end
end
