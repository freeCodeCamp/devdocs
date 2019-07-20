module Docs
  class Lodash < UrlScraper
    self.name = 'lodash'
    self.slug = 'lodash'
    self.type = 'simple'
    self.links = {
      home: 'https://lodash.com/',
      code: 'https://github.com/lodash/lodash/'
    }

    html_filters.push 'lodash/entries', 'lodash/clean_html', 'title'

    options[:title] = 'lodash'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; JS Foundation and other contributors<br>
      Licensed under the MIT License.
    HTML

    version '4' do
      self.release = '4.17.10'
      self.base_url = "https://lodash.com/docs/#{release}"
    end

    version '3' do
      self.release = '3.10.1'
      self.base_url = "https://lodash.com/docs/#{release}"
    end

    version '2' do
      self.release = '2.4.2'
      self.base_url = "https://lodash.com/docs/#{release}"
    end
  end
end
