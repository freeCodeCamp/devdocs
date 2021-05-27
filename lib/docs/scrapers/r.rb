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
    options[:skip_patterns] = [
      /\/DESCRIPTION$/,
      /\/NEWS(\.[^\/]*)?$/,
      /\/demo$/,
      /\.pdf$/
    ]

    ## We want to fix links like so − but only if the targets don’t exist,
    ## as these target packages or keywords that do not have their own file,
    ## but exist on another page, and we properly record it.
    #
    #options[:fix_urls] = ->(url) do
    #  url.sub!(%r'/library/([^/]+)/doc/index.html$') { |m| "/r-#{$1.parameterize.downcase}/" }
    #  url.sub!(%r'/library/([^/]+)/html/([^/]+).html$') { |m| "/library/#{$1.parameterize.downcase}/html/#{$2.parameterize.downcase}" }
    #end

    options[:skip] = %w(
      doc/html/packages-head-utf8.html
      doc/html/SearchOn.html
      doc/html/Search.html
      doc/html/UserManuals.html
      doc/html/faq.html
      doc/manual/R-FAQ.html
      doc/manual/R-admin.html
      doc/manual/R-exts.html
      doc/manual/R-ints.html
      doc/manual/R-lang.html
    )

  end
end
