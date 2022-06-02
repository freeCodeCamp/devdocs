module Docs
  class Groovy < UrlScraper
    self.type = 'groovy'
    self.root_path = 'overview-summary.html'
    self.links = {
      home: 'https://groovy-lang.org/',
      code: 'https://github.com/apache/groovy'
    }

    html_filters.push 'groovy/clean_html', 'groovy/entries'

    options[:skip] = %w(
      index-all.html
      deprecated-list.html
      help-doc.html
    )
    options[:skip_patterns] = [
      /\Aindex.html/
    ]

    options[:attribution] = <<-HTML
      &copy; 2003-2022 The Apache Software Foundation<br>
      Licensed under the Apache license.
    HTML

    version '4.0' do
      self.release = '4.0.0'
      self.base_url = "https://docs.groovy-lang.org/#{self.release}/html/gapi/"
    end

    version '3.0' do
      self.release = '3.0.9'
      self.base_url = "https://docs.groovy-lang.org/#{self.release}/html/gapi/"
    end

    version '2.5' do
      self.release = '2.5.14'
      self.base_url = "https://docs.groovy-lang.org/#{self.release}/html/gapi/"
    end

    version '2.4' do
      self.release = '2.4.21'
      self.base_url = "https://docs.groovy-lang.org/#{self.release}/html/gapi/"
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://groovy.apache.org/download.html', opts)
      doc.at_css('#big-download-button').content.split(' ').last
    end
  end
end
