module Docs
  class Lua < UrlScraper
    self.type = 'lua'
    self.version = '5.3'
    self.base_url = 'http://www.lua.org/manual/5.3/'
    self.root_path = 'manual.html'

    html_filters.push 'lua/clean_html', 'lua/entries'

    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 1994&ndash;2015 Lua.org, PUC-Rio.<br>
      Licensed under the MIT License.
    HTML
  end
end
