module Docs
  class Less < UrlScraper
    self.type = 'less'
    self.release = '2.5.3'
    self.base_url = 'http://lesscss.org'
    self.root_path = '/features'
    self.initial_paths = %w(/functions)
    self.links = {
      home: 'http://lesscss.org/',
      code: 'https://github.com/less/less.js'
    }

    html_filters.push 'less/clean_html', 'less/entries', 'title'

    options[:title] = 'Less'
    options[:container] = 'div[role=main]'
    options[:follow_links] = false
    options[:trailing_slash] = false

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2015 The Core Less Team<br>
      Licensed under the Creative Commons Attribution License 3.0.
    HTML
  end
end
