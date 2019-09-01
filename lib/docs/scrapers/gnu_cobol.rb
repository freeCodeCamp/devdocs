module Docs
  class GnuCobol < UrlScraper
    self.name = 'GnuCOBOL'
    self.slug = 'gnu_cobol'
    self.type = 'simple'
    self.release = '2.2'
    self.base_url = 'https://open-cobol.sourceforge.io/HTML/gnucobpg.html'
    self.links = {
      home: 'https://sourceforge.net/projects/open-cobol/',
      code: 'https://sourceforge.net/p/open-cobol/code/HEAD/tree/trunk/'
    }

    html_filters.push 'gnu_cobol/entries', 'gnu_cobol/clean_html'

    options[:attribution] = <<-HTML
      Copyright &copy; 2000, 2001, 2002, 2007, 2008 Free Software Foundation, Inc.<br>
      Licensed under the GNU Free Documentation License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://open-cobol.sourceforge.io/HTML/gnucobpg.html', opts)
      title = doc.at_css('h1').content
      title.scan(/([0-9.]+)/)[0][0]
    end
  end
end
