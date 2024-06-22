# coding: utf-8
module Docs
  class Latex < UrlScraper
    self.name = 'LaTeX'
    self.slug = 'latex'
    self.type = 'simple'
    self.release = 'May 2022'
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

    def get_latest_version(opts)
      body = fetch('https://latexref.xyz/', opts)
      body = body.scan(/\(\w+\s\d+\)/)[0]
      body.sub!('(', '')
      body.sub!(')', '')
    end

  end
end
