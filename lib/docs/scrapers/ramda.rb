module Docs
  class Ramda < UrlScraper
    self.type = 'ramda'
    self.release = '0.26.1'
    self.base_url = "https://ramdajs.com/#{release}/docs/"
    self.links = {
      home: 'http://ramdajs.com/',
      code: 'https://github.com/ramda/ramda/'
    }

    html_filters.push 'ramda/entries', 'ramda/clean_html', 'title'

    options[:title] = 'Ramda'
    options[:attribution] = <<-HTML
      &copy; 2013&ndash;2016 Scott Sauyet and Michael Hurley<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://ramdajs.com/docs/', opts)
      doc.at_css('.navbar-brand > .version').content[1..-1]
    end
  end
end
