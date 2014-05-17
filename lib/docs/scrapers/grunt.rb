module Docs
  class Grunt < UrlScraper
    self.name = 'Grunt'
    self.type = 'grunt'
    self.version = '0.4.5'
    self.base_url = 'http://gruntjs.com/'
    self.root_path = 'getting-started'
    self.initial_paths = %w(api/grunt)

    html_filters.push 'grunt/clean_html', 'grunt/entries'

    options[:only] = %w(
      configuring-tasks
      sample-gruntfile
      creating-tasks
      using-the-cli
    )
    options[:only_patterns] = [/\Aapi\//]

    options[:container] = '.container > .row-fluid'

    options[:attribution] = <<-HTML
      &copy; 2014 Grunt Team<br>
      Licensed under the MIT License.
    HTML
  end
end
