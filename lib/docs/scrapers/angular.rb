module Docs
  class Angular < UrlScraper
    self.name = 'Angular.js'
    self.slug = 'angular'
    self.type = 'angular'
    self.version = '1.3.8'
    self.base_url = "https://code.angularjs.org/#{version}/docs/partials/api/"

    html_filters.push 'angular/clean_html', 'angular/entries', 'title'
    text_filters.push 'angular/clean_urls'

    options[:title] = false
    options[:root_title] = 'Angular.js'

    options[:fix_urls] = ->(url) do
      url.sub! '/partials/api/api/', '/partials/api/'
      url.sub! %r{/api/(.+?)/api/}, '/api/'
      url.sub! %r{/partials/api/(.+?)(?<!\.html)(?:\z|(#.*))}, '/partials/api/\1.html\2'
      url
    end

    options[:skip] = %w(ng.html)
    options[:skip_patterns] = [/\/(function|directive|object|type|provider|service|filter)\.html\z/]

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2014 Google, Inc.<br>
      Licensed under the Creative Commons Attribution License 3.0.
    HTML

    private

    def request_one(url)
      stub_root_page if url == root_url.to_s
      super
    end

    def request_all(urls, &block)
      stub_root_page
      super
    end

    def stub_root_page
      response = Typhoeus::Response.new(
        effective_url: root_url.to_s,
        code: 200,
        headers: { 'Content-Type' => 'text/html' },
        body: get_root_page_body)

      Typhoeus.stub(root_url.to_s).and_return(response)
    end

    def get_root_page_body
      require 'capybara'
      Capybara.current_driver = :selenium
      Capybara.visit("https://code.angularjs.org/#{self.class.version}/docs/api")
      Capybara.find('.side-navigation')['innerHTML']
    end
  end
end
