module Docs
  class Elasticsearch < UrlScraper
    self.name = 'ElasticSearch'
    self.slug = 'elasticsearch'
    self.type = 'elasticsearch'
    self.version = '1.6'
    self.base_url = "https://www.elastic.co/guide/en/elasticsearch/reference/#{version}/"
    self.root_path = 'index.html'

    html_filters.push 'elasticsearch/entries', 'elasticsearch/clean_html'

    options[:container] = '#guide'

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2015 Elasticsearch <br>
      Licensed under the Apache License, Version 2.0.
    HTML

  end
end

