module Docs
  class Gnuplot < FileScraper
    self.type = 'gnuplot'
    self.release = '5.4.0'
    self.links = {
      home: 'http://www.gnuplot.info/',
      code: 'https://sourceforge.net/projects/gnuplot/'
    }

    self.root_path = 'nofigures.html'

    html_filters.push 'gnuplot/entries', 'gnuplot/clean_html'

    options[:skip_links] = false

    options[:skip] = %w(
      Copyright.html
      External_libraries.html
      Known_limitations.html
      Introduction.html
      About_this_document.html
      New_features.html
      Differences_from_version_4.html
      Seeking_assistance.html
      Gnuplot.html
      Deprecated_syntax.html
      Demos_Online_Examples.html
      Terminal_types.html
      Plotting_styles.html
      Commands.html
      Contents.html
      Bugs.html
      Index.html
    )

    options[:attribution] = <<-HTML
      Copyright 1986 - 1993, 1998, 2004   Thomas Williams, Colin Kelley<br>
      Distributed under the <a href="https://sourceforge.net/p/gnuplot/gnuplot-main/ci/master/tree/Copyright">gnuplot license</a> (rights to distribute modified versions are withheld).
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('http://www.gnuplot.info/download.html', opts)
      label = doc.at_css('h2').content.strip
      label.sub(/[^0-9.]*/, '')
    end
  end
end
