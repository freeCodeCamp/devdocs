module Docs
  class Dart < FileScraper
    self.type = 'dart'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://www.dartlang.org/',
      code: 'https://github.com/dart-lang/sdk'
    }

    html_filters.push 'dart/entries', 'dart/clean_html'

    options[:fix_urls] = ->(url) do
      # localhost/dart-web_audio/..dart-io/dart-io-library.html > localhost/dart-io/dart-io-library.html
      url.sub(/(([^\/]+)\/\.\.)/, '')
    end

    options[:attribution] = <<-HTML
      &copy; 2012, the Dart project authors<br>
      Licensed under the Creative Commons Attribution-ShareAlike License v4.0.
    HTML

    # Download the documentation from https://www.dartlang.org/tools/sdk/archive

    version '1' do
      self.release = '1.24.3'
      self.dir = '/home/jasper/Documents/dart-docs-1.24.3'
    end

    version '2' do
      self.release = '2.0.0-dev.68.0'
      self.dir = '/home/jasper/Documents/dart-docs-2.0.0-dev.68.0'
    end
  end
end
