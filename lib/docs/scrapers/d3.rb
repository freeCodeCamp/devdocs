module Docs
  class D3 < UrlScraper
    self.name = 'D3.js'
    self.slug = 'd3'
    self.type = 'd3'
    self.links = {
      home: 'https://d3js.org/',
      code: 'https://github.com/d3/d3'
    }

    options[:max_image_size] = 150_000
    options[:container] = '.markdown-body'

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2017 Michael Bostock<br>
      Licensed under the BSD License.
    HTML

    version '4' do
      self.release = '4.12.2'
      self.base_url = 'https://github.com/d3/'
      self.root_path = 'd3/blob/master/API.md'

      html_filters.push 'd3/clean_html', 'd3/entries_v4'

      options[:only_patterns] = [/\Ad3[\-\w]+\z/, /\Ad3\/blob\/master\/changes\.md\z/i]
      options[:skip_patterns] = [/3\.x-api-reference/]

      options[:fix_urls] = ->(url) do
        url.sub! %r{/blob/master/readme.md}i, ''
        url
      end
    end

    version '3' do
      self.release = '3.5.17'
      self.base_url = 'https://github.com/d3/d3-3.x-api-reference/blob/master/'
      self.root_path = 'API-Reference.md'

      html_filters.push 'd3/clean_html', 'd3/entries_v3', 'title'

      options[:root_title] = 'D3.js'
      options[:only_patterns] = [/\.md\z/]
    end
  end
end
