module Docs
  class R < FileScraper
    self.name = 'R'
    self.slug = 'r'
    self.type = 'simple'
    self.release = '4.1.0'
    self.links = {
      home: 'https://www.r-project.org/',
      code: 'https://svn.r-project.org/R/'
    }

    self.root_path = 'doc/html/packages.html'

    html_filters.push 'r/entries', 'r/clean_html'

    options[:skip_links] = false

    options[:attribution] = <<-HTML
      Copyright (&copy;) 1999–2012 R Foundation for Statistical Computing.<br>
      Licensed under the <a href="https://www.gnu.org/copyleft/gpl.html">GNU General Public License</a>.
    HTML

    # Never want those
    options[:skip] = %w(
      doc/html/packages-head-utf8.html
      doc/html/SearchOn.html
      doc/html/Search.html
    )

  end
end
