module Docs
  class Electron < UrlScraper
    self.type = 'simple'
    self.base_url = 'https://electronjs.org/docs'
    self.release = '2.0.2'
    self.links = {
      home: 'https://electronjs.org/',
      code: 'https://github.com/electron/electron'
    }

    html_filters.push 'electron/clean_html', 'electron/entries'

    options[:trailing_slash] = false
    options[:container] = '.page-section > .container, .page-section > .container-narrow'
    options[:skip] = %w(guides development tutorial versions all)
    options[:skip_patterns] = [/\/history\z/]
    options[:replace_paths] = {
      'api/web-view-tag' => 'api/webview-tag'
    }

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;2018 GitHub Inc.<br>
      Licensed under the MIT license.
    HTML
  end
end
