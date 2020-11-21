module Docs
  class Underscore < UrlScraper
    self.name = 'Underscore.js'
    self.slug = 'underscore'
    self.type = 'underscore'
    self.release = '1.11.0'
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
      &copy; 2009&ndash;2020 Jeremy Ashkenas, DocumentCloud and Investigative Reporters &amp; Editors<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://underscorejs.org/', opts)
      doc.at_css('.version').content[1...-1]
    end
  end
end
