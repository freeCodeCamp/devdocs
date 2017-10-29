module Docs
  class Cordova < UrlScraper
    self.name = 'Cordova'
    self.type = 'cordova'
    self.root_path = 'guide/overview/index.html'
    self.links = {
      home: 'https://cordova.apache.org/',
      code: 'https://git-wip-us.apache.org/repos/asf/cordova-cli.git'
    }

    html_filters.push 'cordova/entries', 'cordova/clean_html'

    options[:container] = '.docs'
    options[:skip] = %w(index.html)

    options[:fix_urls] = ->(url) do
      if url.include?('https://cordova.apache.org/docs') && !url.end_with?('.html')
        if url.end_with?('/')
          url << 'index.html'
        else
          url << '/index.html'
        end
      end
    end

    options[:attribution] = <<-HTML
      &copy; 2012&ndash;2017 The Apache Software Foundation<br>
      Licensed under the Apache License 2.0.
    HTML

    version '7' do
      self.release = '7.1.0'
      self.base_url = 'https://cordova.apache.org/docs/en/7.x/'
    end

    version '6' do
      self.release = '6.5.0'
      self.base_url = 'https://cordova.apache.org/docs/en/6.x/'
    end
  end
end
