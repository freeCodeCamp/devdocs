module Docs
  class Gnu < FileScraper
    self.type = 'simple'
    self.root_path = 'index.html'
    self.abstract = 'true'

    html_filters.push 'gnu/clean_html', 'gnu/entries'

    options[:skip] = %w(
      GNU-Project.html
      Service.html
    )

    options[:skip_patterns] = [
      /Funding/,
      /Projects/,
      /Copying/,
      /License/,
      /Proposed/,
      /Contribut/,
      /Index/,
      /\ABug/
    ]

    options[:attribution] = <<-HTML
      &copy; Free Software Foundation<br>
      Licensed under the GNU Free Documentation License, Version 1.3.
    HTML
  end
end
