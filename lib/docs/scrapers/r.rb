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
      /\/doc\/index\.html$/,
      /\/demo$/,
      /\.pdf$/
    ]

    options[:replace_paths] = {
    ## We want to fix links like so − but only if the targets don’t exist:
    #  'library/MASS/html/cov.mve.html' => 'library/MASS/html/cov.rob.html'
    ## Paths for target packages or keywords that do not have their own file
    ## are generated in the entries filter from 00Index.html files
    }

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

    def get_latest_version(opts)
      body = fetch('https://cran.r-project.org/src/base/NEWS', opts)
      body.match(/CHANGES IN R ([\d.]+):/)[1]
    end

  end
end
