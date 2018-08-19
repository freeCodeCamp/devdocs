module Docs
  class Julia < UrlScraper
    self.links = {
      home: 'https://julialang.org/',
      code: 'https://github.com/JuliaLang/julia'
    }

    options[:only_patterns] = [/\Amanual\//, /\Astdlib\//]

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2016 Jeff Bezanson, Stefan Karpinski, Viral B. Shah, and other contributors<br>
      Licensed under the MIT License.
    HTML

    version '1.0' do
      self.release = '1.0.0'
      self.base_url = "https://docs.julialang.org/en/v#{release}/"
      self.type = 'julia'

      html_filters.push 'julia/entries', 'julia/clean_html'

      options[:container] = '#docs'
    end

    version '0.7' do
      self.release = '0.7.0'
      self.base_url = "https://docs.julialang.org/en/v#{release}/"
      self.type = 'julia'

      html_filters.push 'julia/entries', 'julia/clean_html'

      options[:container] = '#docs'
    end

    version '0.6' do
      self.release = '0.6.2'
      self.base_url = "https://docs.julialang.org/en/v#{release}/"
      self.type = 'julia'

      html_filters.push 'julia/entries', 'julia/clean_html'

      options[:container] = '#docs'
    end

    version '0.5' do
      self.release = '0.5.2'
      self.base_url = "https://docs.julialang.org/en/v#{release}/"
      self.type = 'sphinx_simple'

      html_filters.push 'julia/entries_sphinx', 'julia/clean_html_sphinx', 'sphinx/clean_html'
    end
  end
end
