module Docs
  class GnuFortran < FileScraper
    self.name = 'GNU Fortran'
    self.slug = 'gnu_fortran'
    self.type = 'gnu_fortran'
    self.dir = '/Users/Thibaut/DevDocs/Docs/gfortran'
    self.root_path = 'index.html'

    self.links = {
      home: 'https://gcc.gnu.org/fortran/'
    }

    html_filters.push 'gnu_fortran/clean_html', 'gnu_fortran/entries'

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
      Licensed under the GNU Free Documentation License, Version 1.3.
    HTML

    version '5' do
      self.release = '5.3.0'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gfortran/"
    end

    version '4' do
      self.release = '4.9.3'
      self.base_url = "https://gcc.gnu.org/onlinedocs/gcc-#{release}/gfortran/"
    end
  end
end
