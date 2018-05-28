module Docs
  class Sass < UrlScraper
    self.type = 'yard'
    self.release = '3.5.3'
    self.base_url = 'http://sass-lang.com/documentation/'
    self.root_path = 'file.SASS_REFERENCE.html'
    self.links = {
      home: 'http://sass-lang.com/',
      code: 'https://github.com/sass/sass'
    }

    html_filters.push 'sass/clean_html', 'sass/entries', 'title'

    options[:only] = %w(Sass/Script/Functions.html)
    options[:root_title] = false
    options[:title] = 'Sass Functions'

    options[:container] = ->(filter) do
      filter.root_page? ? '#filecontents' : '#instance_method_details'
    end

    options[:attribution] = <<-HTML
      &copy; 2006&ndash;2016 Hampton Catlin, Nathan Weizenbaum, and Chris Eppstein<br>
      Licensed under the MIT License.
    HTML
  end
end
