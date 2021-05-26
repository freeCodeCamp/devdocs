module Docs
  class Latex < UrlScraper
    self.name = 'LaTeX'
    self.slug = 'latex'
    self.type = 'simple'
    self.links = {
        home: 'https://ctan.org/pkg/latex2e-help-texinfo/'
    }

    self.base_url = 'http://latexref.xyz'

    html_filters.push 'latex/entries', 'latex/clean_html'

    options[:skip_patterns] = [/^\/dev\//, /\.(dvi|pdf)$/]

    options[:attribution] = <<-HTML
      &copy; 2007–2018 Karl Berry<br>
      Public Domain Software
    HTML

  end
end
