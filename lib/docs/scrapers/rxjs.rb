require 'yajl/json_gem'

module Docs
  class Rxjs < UrlScraper
    self.name = 'RxJS'
    self.type = 'rxjs'
    self.links = {
      home: 'https://rxjs.dev/',
      code: 'https://github.com/ReactiveX/rxjs'
    }

    options[:max_image_size] = 256_000

    options[:attribution] = <<-HTML
      &copy; 2015&ndash;2018 Google, Inc., Netflix, Inc., Microsoft Corp. and contributors.<br>
      Code licensed under an Apache-2.0 License. Documentation licensed under CC BY 4.0.
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
      self.release = '6.3.3'
      self.base_url = 'https://rxjs.dev/'
      self.root_path = 'guide/overview'

      html_filters.push 'rxjs/clean_html', 'rxjs/entries'

      options[:follow_links] = false
      options[:only_patterns] = [/\Aguide/, /\Aapi/]
      options[:fix_urls_before_parse] = ->(url) do
        url.sub! %r{\Aguide/}, '/guide/'
        url.sub! %r{\Aapi/}, '/api/'
        url.sub! %r{\Agenerated/}, '/generated/'
        url
      end

      include Docs::Rxjs::Common
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
