module Docs
  class Julia < UrlScraper
    self.type = 'sphinx_simple'
    self.release = '0.4.6'
    self.base_url = 'http://docs.julialang.org/en/release-0.4/'
    self.links = {
      home: 'http://julialang.org/',
      code: 'https://github.com/JuliaLang/julia'
    }

    html_filters.push 'julia/entries', 'julia/clean_html', 'sphinx/clean_html'

    options[:only_patterns] = [/\Amanual\//, /\Astdlib\//]

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2015 Jeff Bezanson, Stefan Karpinski, Viral B. Shah, and other contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
