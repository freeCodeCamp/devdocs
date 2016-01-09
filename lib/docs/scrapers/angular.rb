module Docs
  class Angular < UrlScraper
    include StubRootPage

    self.name = 'Angular.js'
    self.slug = 'angular'
    self.type = 'angular'
    self.version = '1.4.8'
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

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2016 Google, Inc.<br>
      Licensed under the Creative Commons Attribution License 4.0.
    HTML

    private

    def root_page_body
      require 'capybara'
      Capybara.current_driver = :selenium
      Capybara.visit("https://code.angularjs.org/#{self.class.version}/docs/api")
      Capybara.find('.side-navigation')['innerHTML']
    end
  end
end
