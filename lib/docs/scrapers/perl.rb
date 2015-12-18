module Docs
  class Perl < FileScraper
    self.name = 'Perl'
    self.type = 'perl'
    self.release = '5.22.0'
    self.dir = ''
    self.base_url = 'http://perldoc.perl.org/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://www.perl.org/'
    }

    html_filters.push 'perl/entries', 'perl/clean_html'

    options[:skip] = %w(
      preferences.html
      perlartistic.html
      perlgpl.html
      perlhist.html
      perltodo.html
      perlunifaq.html
    )

    options[:skip_patterns] = [
      /\.pdf/,
      /delta\.html/,
      /\Aperlfaq/
    ]

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2015 <br>
      Dual Licensed under the GNU General Public License version 1+ or the Artistic License.
    HTML
  end
end
