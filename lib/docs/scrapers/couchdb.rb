module Docs
  class Couchdb < UrlScraper
    self.name = 'CouchDB'
    self.type = 'couchdb'
    self.root_path = 'index.html'
    
    self.links = {
      home: 'https://couchdb.apache.org/',
      code: 'https://github.com/apache/couchdb'
    }

    html_filters.push 'couchdb/clean_html', 'couchdb/entries'

    options[:container] = 'div[itemprop=articleBody]'
    options[:only_patterns] = [
      /api\//,
      /cluster\//,
      /ddocs\//,
      /replication\//,
      /maintenance\//,
      /partitioned-dbs\//,
      /json\-structure*/
    ]
    options[:rate_limit] = 50 # Docs are subject to Cloudflare limiters.
    options[:attribution] = <<-HTML
      Copyright &copy; 2025 The Apache Software Foundation &mdash; Licensed under the Apache License 2.0
    HTML

    version '3.5' do
      self.release = '3.5.1'
      self.base_url = "https://docs.couchdb.org/en/#{self.release}"
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://couchdb.apache.org/', opts)
      doc.at_css('.download-pane > h2').content.split(' ').last
    end
  end
end
