module Docs
  class Underscore < UrlScraper
    self.name = 'Underscore.js'
    self.slug = 'underscore'
    self.type = 'underscore'
    self.release = '1.9.1'
    self.base_url = 'https://underscorejs.org'
    self.links = {
      home: 'https://underscorejs.org',
      code: 'https://github.com/jashkenas/underscore'
    }

    html_filters.push 'underscore/clean_html', 'underscore/entries', 'title'

    options[:title] = 'Underscore.js'
    options[:container] = '#documentation'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2018 Jeremy Ashkenas, DocumentCloud and Investigative Reporters &amp; Editors<br>
      Licensed under the MIT License.
    HTML
  end
end
