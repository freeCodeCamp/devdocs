module Docs
  class Hammerspoon < UrlScraper
    self.type = 'hammerspoon'
    self.root_path = ''
    self.links = {
      home: 'https://www.hammerspoon.org',
      code: 'https://github.com/Hammerspoon/hammerspoon'
    }

    html_filters.push 'hammerspoon/clean_html', 'hammerspoon/entries'

    # links with no content will still render a page, this is an error in the docs
    # (see: https://github.com/Hammerspoon/hammerspoon/pull/3579)
    options[:skip] = ['module.lp/matrix.md']
    # Replace '/module.lp/' with '' in URLs
    options[:replace_paths] = { 'localhost:12345/module.lp/MATRIX.md' => 'localhost:12345/module.lp/hs.canvas.matrix' }

    # Hammerspoon docs don't have a license (MIT specified in the hammerspoon repo)
    # https://github.com/Hammerspoon/hammerspoon/blob/master/LICENSE
    options[:attribution] = <<-HTML
      Hammerspoon
    HTML


    version '0.9.100' do
      self.release = '0.9.100'
      # add `hs.doc.hsdocs.start()` to your init.lua to enable the docs server
      self.base_url = 'http://localhost:12345/'
    end

  end
end
