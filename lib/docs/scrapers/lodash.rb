module Docs
  class Lodash < UrlScraper
    self.name = 'lodash'
    self.slug = 'lodash'
    self.type = 'lodash'
    self.links = {
      home: 'https://lodash.com/',
      code: 'https://github.com/lodash/lodash/'
    }

    html_filters.push 'lodash/entries', 'lodash/clean_html', 'title'

    options[:title] = 'lodash'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2012&ndash;2016 The Dojo Foundation<br>
      Licensed under the MIT License.
    HTML

    version '4' do
      self.release = '4.11.1'
      self.base_url = 'https://lodash.com/docs'
    end

    version '3' do
      self.release = '3.10.0'
      self.base_url = 'https://lodash.com/docs' # OUT-OF-DATE
    end
  end
end
