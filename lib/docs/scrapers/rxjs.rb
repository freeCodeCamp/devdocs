require 'yajl/json_gem'

module Docs
  class Rxjs < UrlScraper
    self.name = 'RxJS'
    self.type = 'rxjs'
    self.release = '7.5.5'
    self.base_url = 'https://rxjs.dev/'
    self.root_path = 'guide/overview'
    self.links = {
      home: 'https://rxjs.dev/',
      code: 'https://github.com/ReactiveX/rxjs'
    }

    html_filters.push 'rxjs/clean_html', 'rxjs/entries'

    options[:follow_links] = false
    options[:only_patterns] = [/guide\//, /api\//]
    options[:skip_patterns] = [/api\/([^\/]+)\.json/]
    options[:fix_urls_before_parse] = ->(url) do
      url.sub! %r{\A(\.\/)?guide/}, '/guide/'
      url.sub! %r{\Aapi/}, '/api/'
      url.sub! %r{\Agenerated/}, '/generated/'
      url
    end

    options[:max_image_size] = 256_000

    options[:attribution] = <<-HTML
      &copy; 2015&ndash;2022 Google, Inc., Netflix, Inc., Microsoft Corp. and contributors.<br>
      Code licensed under an Apache-2.0 License. Documentation licensed under CC BY 4.0.
    HTML

    def get_latest_version(opts)
      json = fetch_json('https://rxjs.dev/generated/navigation.json', opts)
      json['__versionInfo']['raw']
    end

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

      initial_urls.select do |url|
        options[:only_patterns].any? { |pattern| url =~ pattern } &&
          options[:skip_patterns].none? { |pattern| url =~ pattern }
      end
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
