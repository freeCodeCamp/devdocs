module Docs
  class D3 < UrlScraper
    self.name = 'D3.js'
    self.slug = 'd3'
    self.type = 'd3'
    self.version = '3.5.12'
    self.base_url = 'https://github.com/mbostock/d3/wiki/'
    self.root_path = 'API-Reference'
    self.links = {
      home: 'http://d3js.org/',
      code: 'https://github.com/mbostock/d3'
    }

    html_filters.push 'd3/clean_html', 'd3/entries'

    options[:container] = '#wiki-wrapper'

    options[:only] = %w(
      Selections
      Transitions
      Arrays
      Math
      Requests
      Formatting
      CSV
      Localization
      Colors
      Namespaces
      Internals)

    options[:only_patterns] = [
      /\-Scales\z/,
      /\ASVG\-\w/,
      /\ATime\-/,
      /\-Layout\z/,
      /\AGeo\-/,
      /\-Geom\z/,
      /\-Behavior\z/]

    options[:skip_patterns] = [/\//]

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2016 Michael Bostock<br>
      Licensed under the BSD License.
    HTML
  end
end
