module Docs
  class Chef < UrlScraper
    self.name = 'Chef'
    self.slug = 'chef'
    self.type = 'chef'
    self.version = '12.5'
    self.base_url = 'https://docs.chef.io/'
    self.links = {
      home: 'https://www.chef.io/',
      docs: 'https://docs.chef.io/'
    }

    html_filters.push 'chef/entries', 'chef/clean_html'

    options[:container] = '.bodywrapper'

    options[:only_patterns] = [/resource_.*.html/]
    options[:skip_patterns] = [/resource_common\.html/]

    options[:trailing_slash] = false

    options[:attribution] = <<-HTML
      &copy; 2015 Chef Software, Inc.<br>
      Creative Commons Attribution 3.0 Unported License.
    HTML
  end
end
