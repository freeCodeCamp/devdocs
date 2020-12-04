module Docs
  class Perl < UrlScraper
    self.name = 'Perl'
    self.type = 'perl'
#    self.root_path = 'index.html'
    self.initial_paths = ['modules.html', 'perlutil.html', 'perl.html']
    self.links = {
      home: 'https://www.perl.org/'
    }

    html_filters.push 'perl/pre_clean_html', 'perl/entries', 'perl/clean_html', 'title'

    options[:container] = '#perldocdiv'

    options[:skip] = %w(
      perlbook perlcommunity perlexperiment perlartistic perlgpl perlhist
      perlcn perljp perlko perltw
      perlboot perlbot perlrepository perltodo perltooc perltoot )

    options[:skip_patterns] = [/\Afunctions/, /\Avariables/, /\.pdf/, /delta/]

    options[:attribution] = <<-HTML
      &copy; 1993&ndash;2020 Larry Wall and others<br>
      Licensed under the GNU General Public License version 1 or later, or the Artistic License.<br>
      The Perl logo is a trademark of the Perl Foundation.
    HTML

    version '5.32' do
      self.release = '5.32.0'
      self.base_url = "https://perldoc.perl.org/#{self.release}/"
    end

    version '5.30' do
      self.release = '5.30.3'
      self.base_url = "https://perldoc.perl.org/#{self.release}/"
    end

    version '5.28' do
      self.release = '5.28.3'
      self.base_url = "https://perldoc.perl.org/#{self.release}/"
    end

    version '5.26' do
      self.release = '5.26.3'
      self.base_url = "https://perldoc.perl.org/#{self.release}/"
    end

    version '5.24' do
      self.release = '5.24.4'
      self.base_url = "https://perldoc.perl.org/#{self.release}/"
    end

    version '5.22' do
      self.release = '5.22.4'
      self.base_url = "https://perldoc.perl.org/#{self.release}/"
    end

    version '5.20' do
      self.release = '5.20.3'
      self.base_url = "https://perldoc.perl.org/#{self.release}/"
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://perldoc.perl.org/', opts)
      doc.at_css('#dropdownlink-stable').content
    end
  end
end
