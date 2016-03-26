module Docs
  class Lua < UrlScraper
    self.type = 'lua'
    self.root_path = 'manual.html'

    html_filters.push 'lua/clean_html', 'lua/entries'

    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 1994&ndash;2015 Lua.org, PUC-Rio.<br>
      Licensed under the MIT License.
    HTML

    version '5.3' do
      self.release = '5.3'
      self.base_url = 'https://www.lua.org/manual/5.3/'
    end

    version '5.2' do
      self.release = '5.2'
      self.base_url = 'https://www.lua.org/manual/5.2/'
    end

    version '5.1' do
      self.release = '5.1'
      self.base_url = 'https://www.lua.org/manual/5.1/'
    end
  end
end
