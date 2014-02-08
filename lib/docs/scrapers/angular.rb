module Docs
  class Angular < UrlScraper
    self.name = 'Angular.js'
    self.slug = 'angular'
    self.type = 'angular'
    self.version = '1.2.12'
    self.base_url = 'http://docs.angularjs.org/partials/api/'

    html_filters.insert_before 'normalize_paths', 'angular/clean_html'
    html_filters.push 'angular/entries', 'title'
    text_filters.push 'angular/clean_urls'

    options[:title] = false
    options[:root_title] = 'Angular.js'

    options[:fix_urls] = ->(url) do
      url.sub! '/partials/api/api/', '/partials/api/'
      url.sub! '/partials/api/guide/', '/guide/'
      url.sub! %r{/partials/api/(.+?)(?<!\.html)(?:\z|(#.*))}, '/partials/api/\1.html\2'
      url.gsub! '/partials/api/(.+?)\:', '/partials/api/\1%3A'
      url
    end

    options[:skip] = %w(ng.html)

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
      Capybara.visit('http://docs.angularjs.org/api/')
      Capybara.find('.side-navigation')['innerHTML']
    end
  end
end
