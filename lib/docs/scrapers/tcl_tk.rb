module Docs
  class TclTk < UrlScraper
    self.name = 'Tcl/Tk'
    self.type = 'tcl_tk'
    self.slug = 'tcl'
    self.version = '8.6'
    # test URL:
    self.base_url = 'http://localhost/tcl/'
    # real URL:
    #self.base_url = 'http://www.tcl.tk/man/tcl/'
    self.root_path = 'contents.htm'

    html_filters.push 'tcl_tk/clean_html', 'tcl_tk/entries'

    options[:skip_links] = false

    options[:trailing_slash] = false
    options[:skip] = ['siteinfo.htm']
    options[:skip_patterns] = [
	# ignore keyword list pages
	/^Keywords\//,
	# ignore C-API, only required for extension developers
	/^TclLib\//,
	/^TkLib\//,
	/^ItclLib\//,
	/^TdbcLib\//
    ]

    # TODO can't figure out howto convert .htm => .html in filenames
    # to save as "xyz.html" instead of "xyz.htm.html"
    #options[:fix_urls] = ->(url) do
    #  url.sub! /\.htm($|#)/, '.html\\1'
    #  url
    #end

    # Each Page contains a specific list of copyrights, only add the
    # overall license link
    options[:attribution] = <<-HTML
      Licensed under <a href="http://tcl.tk/software/tcltk/license.html">Tcl/Tk Terms</a>
    HTML
  end
end
