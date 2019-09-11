module Docs
  class Cordova < UrlScraper
    self.name = 'Cordova'
    self.type = 'cordova'
    self.root_path = 'guide/overview/index.html'
    self.links = {
      home: 'https://cordova.apache.org/',
      code: 'https://github.com/apache/cordova'
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
      &copy; 2012, 2013, 2015 The Apache Software Foundation<br>
      Licensed under the Apache License 2.0.
    HTML

    version '9' do
      self.release = '9.0.0'
      self.base_url = "https://cordova.apache.org/docs/en/#{self.version}.x/"
    end

    version '8' do
      self.release = '8.1.2'
      self.base_url = "https://cordova.apache.org/docs/en/#{self.version}.x/"
    end

    version '7' do
      self.release = '7.1.0'
      self.base_url = "https://cordova.apache.org/docs/en/#{self.version}.x/"
    end

    version '6' do
      self.release = '6.5.0'
      self.base_url = "https://cordova.apache.org/docs/en/#{self.version}.x/"
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://cordova.apache.org/docs/en/latest/', opts)

      label = doc.at_css('#versionDropdown').content.strip
      version = label.scan(/([0-9.]+)/)[0][0]
      version = version[0...-1] if version.end_with?('.')

      version
    end
  end
end
