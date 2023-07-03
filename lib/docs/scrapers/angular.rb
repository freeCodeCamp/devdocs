require 'yajl/json_gem'

module Docs
  class Angular < UrlScraper
    self.type = 'angular'
    self.links = {
      home: 'https://angular.io/',
      code: 'https://github.com/angular/angular'
    }
    self.base_url = 'https://angular.io/'
    self.root_path = 'docs'

    html_filters.push 'angular/clean_html', 'angular/entries'

    options[:max_image_size] = 256_000

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2023 Google, Inc.<br>
      Licensed under the Creative Commons Attribution License 4.0.
    HTML

    options[:follow_links] = false
    options[:only_patterns] = [/\Aguide/, /\Atutorial/, /\Aapi/]
    options[:fix_urls_before_parse] = ->(url) do
      url.sub! %r{\Aguide/}, '/guide/'
      url.sub! %r{\Atutorial/}, '/tutorial/'
      url.sub! %r{\Aapi/}, '/api/'
      url.sub! %r{\Agenerated/}, '/generated/'
      url
    end

    module Common
      private

      def initial_urls
        initial_urls = []

        Request.run "#{self.class.base_url}generated/navigation.json" do |response|
          data = JSON.parse(response.body)
          dig = ->(entry) do
            initial_urls << url_for("generated/docs/#{entry['url']}.json") if entry['url'] && entry['url'] != 'api'
            entry['children'].each(&dig) if entry['children']
          end
          data['SideNav'].each(&dig)
        end

        Request.run "#{self.class.base_url}generated/docs/api/api-list.json" do |response|
          data = JSON.parse(response.body)
          dig = ->(entry) do
            initial_urls << url_for("generated/docs/#{entry['path']}.json") if entry['path']
            initial_urls << url_for("generated/docs/api/#{entry['name']}.json") if entry['name'] && !entry['path']
            entry['items'].each(&dig) if entry['items']
          end
          data.each(&dig)
        end

        initial_urls
      end

      def handle_response(response)
        if response.mime_type.include?('json')
          begin
            json = JSON.parse(response.body)
            response.options[:response_body] = json['contents']
            response.url.path = response.url.path.gsub(/generated\/docs\/.*/, json['id'])
            response.effective_url.path = response.effective_url.path.gsub(/generated\/docs\/.*/, json['id'])
          rescue JSON::ParserError
            response.options[:response_body] = ''
          end
          response.headers['Content-Type'] = 'text/html'
        end
        super
      end
    end

    module Since12
      def url_for(path)
        # See encodeToLowercase im aio/tools/transforms/angular-base-package/processors/disambiguateDocPaths.js
        path = path.gsub(/[A-Z_]/) {|s| s.downcase + '_'}
        super
      end
      include Docs::Angular::Common
    end

    version do
      self.release = '16.1.3'
      self.base_url = 'https://angular.io/'
      include Docs::Angular::Since12
    end

    version '15' do
      self.release = '15.2.9'
      self.base_url = 'https://angular.io/'
      include Docs::Angular::Since12
    end

    version '14' do
      self.release = '14.2.12'
      self.base_url = 'https://v14.angular.io/'
      include Docs::Angular::Since12
    end

    version '13' do
      self.release = '13.3.8'
      self.base_url = 'https://v13.angular.io/'
      include Docs::Angular::Since12
    end

    version '12' do
      self.release = '12.2.13'
      self.base_url = 'https://v12.angular.io/'
      include Docs::Angular::Since12
    end

    version '11' do
      self.release = '11.2.14'
      self.base_url = 'https://v11.angular.io/'
      include Docs::Angular::Common
    end

    version '10' do
      self.release = '10.2.3'
      self.base_url = 'https://v10.angular.io/'
      include Docs::Angular::Common
    end

    version '9' do
      self.release = '9.1.12'
      self.base_url = 'https://v9.angular.io/'
      include Docs::Angular::Common
    end

    version '8' do
      self.release = '8.2.14'
      self.base_url = 'https://v8.angular.io/'
      include Docs::Angular::Common
    end

    version '7' do
      self.release = '7.2.15'
      self.base_url = 'https://v7.angular.io/'
      include Docs::Angular::Common
    end

    version '6' do
      self.release = '6.1.10'
      self.base_url = 'https://v6.angular.io/'
      include Docs::Angular::Common
    end

    version '5' do
      self.release = '5.2.11'
      self.base_url = 'https://v5.angular.io/'
      include Docs::Angular::Common
    end

    version '4' do
      self.release = '4.4.6'
      self.base_url = 'https://v4.angular.io/'
      include Docs::Angular::Common
    end

    version '2' do
      self.release = '2.4.10'
      self.base_url = 'https://v2.angular.io/docs/ts/latest/'
      self.root_path = 'api/'

      html_filters.push 'angular/entries_v2', 'angular/clean_html_v2'

      stub 'api/' do
        base_url = URL.parse(self.base_url)
        capybara = load_capybara_selenium
        capybara.app_host = base_url.origin
        capybara.visit(base_url.path + 'api/')
        capybara.execute_script('return document.body.innerHTML')
      end

      options[:skip_patterns] = [/deprecated/, /VERSION-let/]
      options[:skip] = %w(
        index.html
        styleguide.html
        quickstart.html
        cheatsheet.html
        guide/cheatsheet.html
        guide/style-guide.html)

      options[:replace_paths] = {
        'testing/index.html'  => 'guide/testing.html',
        'guide/glossary.html' => 'glossary.html',
        'tutorial'            => 'tutorial/',
        'api'                 => 'api/'
      }

      options[:fix_urls] = -> (url) do
        url.sub! %r{\A(https://(?:v2\.)?angular\.io/docs/.+/)index\.html\z}, '\1'
        url
      end
    end

    def get_latest_version(opts)
      get_npm_version('@angular/core', opts)
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
