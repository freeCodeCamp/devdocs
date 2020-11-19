module Docs
  class GnuCobol < UrlScraper
    self.name = 'GnuCOBOL'
    self.slug = 'gnu_cobol'
    self.type = 'simple'
    self.release = '3.1'
    self.base_url = 'https://gnucobol.sourceforge.io/HTML/gnucobpg.html'
    self.links = {
      home: 'https://gnucobol.sourceforge.io/',
      code: 'https://sourceforge.net/p/gnucobol/code/HEAD/tree/trunk/'
    }

    html_filters.push 'gnu_cobol/entries', 'gnu_cobol/clean_html'

    options[:skip_links] = true

    options[:attribution] = <<-HTML
      Copyright &copy; 2000, 2001, 2002, 2007, 2008 Free Software Foundation, Inc.<br>
      Licensed under the GNU Free Documentation License.
    HTML

    def get_latest_version(opts)
      fetch_doc('https://sourceforge.net/projects/gnucobol/files/gnucobol/', opts)
        .css('#files_list > tbody > tr')
        .map { |file| file['title'] }
        .sort_by { |version| version.to_f }
        .last
    end
  end
end
