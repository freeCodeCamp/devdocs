module Docs
  class Less < UrlScraper
    self.type = 'simple'
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
      &copy; 2009&ndash;2020 The Core Less Team<br>
      Licensed under the Creative Commons Attribution License 3.0.
    HTML

    version '4' do
      self.release = '4.0.0'
    end

    version '3' do
      self.release = '3.12.0'
    end

    version '2' do
      self.release = '2.7.2'
    end

    def get_latest_version(opts)
      doc = fetch_doc('http://lesscss.org/features/', opts)
      label = doc.at_css('.footer-links > li').content
      label.scan(/([0-9.]+)/)[0][0]
    end
  end
end
