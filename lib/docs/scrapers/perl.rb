module Docs
  class Perl < FileScraper
    self.name = 'Perl'
    self.type = 'perl'
    self.dir = '/Users/Thibaut/DevDocs/Docs/Perl'
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
      perltodo.html )

    options[:skip_patterns] = [/\.pdf/, /delta\.html/]

    options[:attribution] = <<-HTML
      &copy; 1993&ndash;2016 Larry Wall and others<br>
      Licensed under the GNU General Public License version 1 or later, or the Artistic License.<br>
      The Perl logo is a trademark of the Perl Foundation.
    HTML

    version '5.26' do
      self.release = '5.26.0'
      self.base_url = "https://perldoc.perl.org/#{self.release}/"
    end

    version '5.24' do
      self.release = '5.24.0'
      self.base_url = "https://perldoc.perl.org/#{self.release}/"
    end

    version '5.22' do
      self.release = '5.22.0'
      self.base_url = "https://perldoc.perl.org/#{self.release}/"
    end

    version '5.20' do
      self.release = '5.20.2'
      self.base_url = "https://perldoc.perl.org/#{self.release}/"
    end
  end
end
