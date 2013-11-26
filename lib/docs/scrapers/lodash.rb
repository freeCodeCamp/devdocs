module Docs
  class Lodash < UrlScraper
    self.name = 'Lo-Dash'
    self.slug = 'lodash'
    self.type = 'lodash'
    self.version = '2.4.0'
    self.base_url = 'http://lodash.com/docs'

    html_filters.push 'lodash/clean_html', 'lodash/entries', 'title'

    options[:title] = 'Lo-Dash'
    options[:container] = 'h1+div+div'
    options[:skip_links] = -> (_) { true }

    options[:attribution] = <<-HTML
      &copy; 2012&ndash;2013 The Dojo Foundation<br>
      Licensed under the MIT License.
    HTML
  end
end
