module Docs
  class Fortran < FileScraper
    self.name = 'GNU Fortran'
    self.slug = 'fortran'
    self.type = 'fortran'
    self.release = '5.3.0'
    self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gfortran/"
    self.dir = ''
    self.root_path = 'index.html'

    self.links = {
      home: 'https://gcc.gnu.org/fortran/'
    }

    html_filters.push 'fortran/clean_html', 'fortran/entries'

    options[:skip_patterns] = [
      /Funding/,
      /Projects/,
      /Copying/,
      /License/,
      /Proposed/,
      /Contribut/,
      /Index/
    ]

    options[:attribution] = <<-HTML
      &copy; Free Software Foundation<br>
      Licensed under the GNU Free Documentation License version 1.3.
    HTML
  end
end
