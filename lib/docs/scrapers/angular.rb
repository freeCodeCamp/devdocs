require 'yajl/json_gem'

module Docs
  class Angular < UrlScraper
    self.type = 'angular'
    self.links = {
      home: 'https://angular.io/',
      code: 'https://github.com/angular/angular'
    }

    options[:max_image_size] = 256_000

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2018 Google, Inc.<br>
      Licensed under the Creative Commons Attribution License 4.0.
    HTML

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
            response.options[:response_body] = JSON.parse(response.body)['contents']
          rescue JSON::ParserError
            response.options[:response_body] = ''
          end
          response.headers['Content-Type'] = 'text/html'
          response.url.path = response.url.path.sub('/generated/docs/', '/').remove('.json')
          response.effective_url.path = response.effective_url.path.sub('/generated/docs/', '/').remove('.json')
        end
        super
      end
    end

    version do
      self.release = '5.2.9'
      self.base_url = 'https://angular.io/'
      self.root_path = 'docs'

      html_filters.push 'angular/clean_html', 'angular/entries'

      options[:follow_links] = false
      options[:only_patterns] = [/\Aguide/, /\Atutorial/, /\Aapi/]
      options[:fix_urls_before_parse] = ->(url) do
        url.sub! %r{\Aguide/}, '/guide/'
        url.sub! %r{\Atutorial/}, '/tutorial/'
        url.sub! %r{\Aapi/}, '/api/'
        url.sub! %r{\Agenerated/}, '/generated/'
        url
      end

      include Docs::Angular::Common
    end

    version '4' do
      self.release = '4.4.6'
      self.base_url = 'https://v4.angular.io/'
      self.root_path = 'docs'

      html_filters.push 'angular/clean_html', 'angular/entries'

      options[:follow_links] = false
      options[:only_patterns] = [/\Aguide/, /\Atutorial/, /\Aapi/]
      options[:fix_urls_before_parse] = ->(url) do
        url.sub! %r{\Aguide/}, '/guide/'
        url.sub! %r{\Atutorial/}, '/tutorial/'
        url.sub! %r{\Aapi/}, '/api/'
        url.sub! %r{\Agenerated/}, '/generated/'
        url
      end

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
