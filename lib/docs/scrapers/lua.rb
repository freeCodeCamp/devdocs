module Docs
  class Lua < UrlScraper
    self.type = 'lua'
    self.root_path = 'manual.html'

    html_filters.push 'lua/clean_html', 'lua/entries'

    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 1994&ndash;2017 Lua.org, PUC-Rio.<br>
      Licensed under the MIT License.
    HTML

    version '5.3' do
      self.release = '5.3.4'
      self.base_url = 'https://www.lua.org/manual/5.3/'
    end

    version '5.2' do
      self.release = '5.2.4'
      self.base_url = 'https://www.lua.org/manual/5.2/'
    end

    version '5.1' do
      self.release = '5.1.5'
      self.base_url = 'https://www.lua.org/manual/5.1/'
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://www.lua.org/manual/', opts)
      doc.at_css('p.menubar > a').content
    end
  end
end
