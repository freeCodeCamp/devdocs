module Docs
  class Grunt < UrlScraper
    self.name = 'Grunt'
    self.type = 'simple'
    self.release = '1.0.1'
    self.base_url = 'https://gruntjs.com/'
    self.root_path = 'getting-started'
    self.initial_paths = %w(api/grunt)

    html_filters.push 'grunt/clean_html', 'grunt/entries'

    options[:only] = %w(
      configuring-tasks
      sample-gruntfile
      creating-tasks
      creating-plugins
      using-the-cli
      installing-grunt
      project-scaffolding
    )
    options[:only_patterns] = [/\Aapi\//, /\Aupgrading-/]

    options[:container] = '.container > .row-fluid'

    options[:attribution] = <<-HTML
      &copy; GruntJS Team<br>
      Licensed under the MIT License.
    HTML
  end
end
