module Docs
  class Zsh < UrlScraper
    self.type = 'zsh'
    self.release = '5.9.0'
    self.base_url = 'https://zsh.sourceforge.io/Doc/Release/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://zsh.sourceforge.io/',
      code: 'https://sourceforge.net/p/zsh/web/ci/master/tree/',
    }

    options[:skip] = %w(
      zsh_toc.html
      zsh_abt.html
      The-Z-Shell-Manual.html
      Introduction.html
    )
    options[:skip_patterns] = [/-Index.html/]

    html_filters.push 'zsh/entries', 'zsh/clean_html'

    options[:attribution] = <<-HTML
      The Z Shell is copyright &copy; 1992&ndash;2017 Paul Falstad, Richard Coleman,
 Zoltán Hidvégi, Andrew Main, Peter Stephenson, Sven Wischnowsky, and others.<br />
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      body = fetch('https://zsh.sourceforge.io/Doc/Release', opts)
      body.scan(/Zsh version ([0-9.]+)/)[0][0]
    end
  end
end
