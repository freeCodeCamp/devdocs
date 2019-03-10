module Docs
  class TclTk < UrlScraper
    self.name = 'Tcl/Tk'
    self.type = 'tcl_tk'
    self.slug = 'tcl_tk'
    self.release = '8.6.6'
    self.base_url = 'https://www.tcl.tk/man/tcl/'
    self.root_path = 'contents.htm'

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
      Licensed under <a href="http://tcl.tk/software/tcltk/license.html">Tcl/Tk terms</a>
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://www.tcl.tk/man/tcl/contents.htm', opts)
      doc.at_css('h2').content.scan(/Tk([0-9.]+)/)[0][0]
    end
  end
end
