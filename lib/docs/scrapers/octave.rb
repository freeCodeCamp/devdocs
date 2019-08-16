module Docs
  class Octave < UrlScraper
    self.name = 'Octave'
    self.type = 'octave'
    self.release = '5.1.0'
    self.base_url = 'https://octave.org/doc/interpreter/'
    self.root_path = 'index.html'
    self.links = {
      home: 'http://www.octave.org/',
      code: 'http://www.octave.org/hg/octave'
    }

    html_filters.push 'octave/clean_html', 'octave/entries', 'title'

    options[:skip] = %w(
      Copying.html
      Preface.html
      Acknowledgements.html
      Citing-Octave-in-Publications.html
      How-You-Can-Contribute-to-Octave.html
      Distribution.html)

    options[:title] = false
    options[:root_title] = 'GNU Octave'

    options[:attribution] = <<-HTML
      &copy; 1996&ndash;2018 John W. Eaton<br>
      Permission is granted to make and distribute verbatim copies of this manual provided the copyright notice and this permission notice are preserved on all copies.<br/>
Permission is granted to copy and distribute modified versions of this manual under the conditions for verbatim copying, provided that the entire resulting derived work is distributed under the terms of a permission notice identical to this one.</br>
Permission is granted to copy and distribute translations of this manual into another language, under the above conditions for modified versions.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://octave.org/doc/interpreter/', opts)
      doc.at_css('h1').content.scan(/([0-9.]+)/)[0][0]
    end
  end
end
