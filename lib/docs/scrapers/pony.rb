module Docs
  class Pony < UrlScraper
    self.type = 'simple'
    self.release = '0.30.0'
    self.base_url = 'https://stdlib.ponylang.io/'
    self.links = {
      home: 'https://www.ponylang.io/',
      code: 'https://github.com/ponylang/ponyc'
    }

    html_filters.push 'pony/clean_html', 'pony/entries'

    options[:attribution] = <<-HTML
      &copy; 2016-2018, The Pony Developers<br>
      &copy; 2014-2015, Causality Ltd.<br>
      Licensed under the BSD 2-Clause License.
    HTML

    options[:container] = 'article'
    options[:trailing_slash] = false
    options[:skip_patterns] = [/src/, /stdlib--index/]

    def get_latest_version(opts)
      get_latest_github_release('ponylang', 'ponyc', opts)
    end
  end
end
