module Docs
  class Angular < UrlScraper
    self.name = 'Angular.js'
    self.slug = 'angular'
    self.type = 'angular'
    self.root_path = 'api.html'
    self.initial_paths = %w(guide.html)

    html_filters.push 'angular/clean_html', 'angular/entries', 'title'
    text_filters.push 'angular/clean_urls'

    options[:title] = false
    options[:root_title] = 'Angular.js'

    options[:decode_and_clean_paths] = true
    options[:fix_urls_before_parse] = ->(str) do
      str.gsub!('[', '%5B')
      str.gsub!(']', '%5D')
      str
    end

    options[:fix_urls] = ->(url) do
      %w(api guide).each do |str|
        url.sub! "/partials/#{str}/#{str}/", "/partials/#{str}/"
        url.sub! %r{/#{str}/img/}, "/img/"
        url.sub! %r{/#{str}/(.+?)/#{str}/}, "/#{str}/"
        url.sub! %r{/partials/#{str}/(.+?)(?<!\.html)(?:\z|(#.*))}, "/partials/#{str}/\\1.html\\2"
      end
      url
    end

    options[:only_patterns] = [%r{\Aapi/}, %r{\Aguide/}]
    options[:skip] = %w(api/ng.html)

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2016 Google, Inc.<br>
      Licensed under the Creative Commons Attribution License 4.0.
    HTML

    version '1.5' do
      self.release = '1.5.3'
      self.base_url = "https://code.angularjs.org/#{release}/docs/partials/"
    end

    version '1.4' do
      self.release = '1.4.10'
      self.base_url = "https://code.angularjs.org/#{release}/docs/partials/"
    end

    version '1.3' do
      self.release = '1.3.20'
      self.base_url = "https://code.angularjs.org/#{release}/docs/partials/"
    end

    version '1.2' do
      self.release = '1.2.29'
      self.base_url = "https://code.angularjs.org/#{release}/docs/partials/"
    end

    stub '' do
      require 'capybara/dsl'
      Capybara.current_driver = :selenium
      Capybara.run_server = false
      Capybara.app_host = 'https://code.angularjs.org'
      Capybara.visit("/#{self.class.release}/docs/api")
      Capybara.find('.side-navigation')['innerHTML']
    end
  end
end
