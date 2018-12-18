module Docs
  class Pony < UrlScraper
    self.type = 'pony'
    self.release = '0.25.0'
    self.base_url = 'https://stdlib.ponylang.io/'

    html_filters.push 'pony/container', 'pony/entries'

    options[:attribution] = <<-HTML
      &copy; 2016-2018, The Pony Developers<br>
      &copy; 2014-2015, Causality Ltd.<br>
      Licensed under the <a href="https://github.com/ponylang/ponyc/blob/master/LICENSE">BSD 2-Clause License</a>
    HTML

    options[:trailing_slash] = false
    options[:skip_patterns] = [/src/]
  end
end
