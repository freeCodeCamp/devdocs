module Docs
  class TclTk < UrlScraper
    self.name = 'Tcl/Tk'
    self.type = 'tcl_tk'
    self.slug = 'tcl_tk'
    self.links = {
      home: 'https://www.tcl-lang.org/',
      code: 'https://sourceforge.net/projects/tcl/files/Tcl/'
    }

    html_filters.push 'tcl_tk/entries', 'tcl_tk/clean_html', 'title'

    options[:root_title] = 'Tcl/Tk Documentation'
    options[:trailing_slash] = false
    options[:skip] = %w(siteinfo.htm)
    options[:skip_patterns] = [
      # ignore keyword list pages
      /\AKeywords\//,
      # ignore C-API, only required for extension developers
      /\ATclLib\//,
      /\ATkLib\//,
      /\AItclLib\//,
      /\ATdbcLib\//
    ]

    options[:attribution] = <<-HTML
      Licensed under <a href="http://www.tcl-lang.org/software/tcltk/license.html">Tcl/Tk terms</a>
    HTML

    version '9.0' do
      self.base_url = "https://www.tcl-lang.org/man/tcl#{self.version}/"
      self.release = '9.0.2'
    end

    version '8.6' do
      self.base_url = "https://www.tcl-lang.org/man/tcl#{self.version}/"
      self.root_path = 'contents.htm'
      self.release = '8.6.16'
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://www.tcl-lang.org/man/tcl/', opts)
      doc.at_css('h2').content.scan(/Tk([0-9.]+)/)[0][0]
    end
  end
end
