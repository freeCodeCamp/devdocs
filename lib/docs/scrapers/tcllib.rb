module Docs
  class Tcllib < UrlScraper
    self.name = 'Tcllib'
    self.type = 'simple'
    self.slug = 'tcllib'
    self.release = '2.0'
    self.base_url = 'https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/'
    self.root_path = 'toc0.md'
    self.links = {
      home: 'https://core.tcl-lang.org/tcllib/doc/trunk/embedded/index.md',
      code: 'https://sourceforge.net/projects/tcllib/files/tcllib/'
    }

    html_filters.push 'tcllib/entries', 'tcllib/clean_html', 'title'
    # The docs have incorrect <base> elements, so we should just skip that
    html_filters.replace('apply_base_url', 'tcllib/nop')

    options[:root_title] = 'Tcllib Documentation'
    options[:container] = '.content'
    options[:skip] = [
      # Full of broken links, path improperly duplicates "tcllib" segment
      'tcllib/toc.md',
      # The other ones aren't terribly useful
      'toc.md', 'toc1.md', 'toc2.md',
      # Keyword index
      'index.md'
    ]

    options[:attribution] = <<-HTML
      Licensed under the <a href="https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/devdoc/tcllib_license.md">BSD license</a>
    HTML


    def get_latest_version(opts)
      doc = fetch_doc('https://core.tcl-lang.org/tcllib/doc/trunk/embedded/index.md', opts)
      doc.at_css('strong').content.scan(/([0-9.]+)/)[0][0]
    end
  end
end
