module Docs
  class Electron < UrlScraper
    self.type = 'electron'
    self.base_url = 'https://electron.atom.io/docs/'
    self.release = '1.7.9'
    self.links = {
      home: 'https://electron.atom.io/',
      code: 'https://github.com/electron/electron'
    }

    html_filters.push 'electron/clean_html', 'electron/entries', 'rouge'

    options[:trailing_slash] = true
    options[:container] = '.page-section > .container, .page-section > .container-narrow'
    options[:skip] = %w(guides/ development/ tutorial/ versions/ all/)
    options[:replace_paths] = {
      'api/web-view-tag/' => 'api/webview-tag/',
      'api/web-view-tag' => 'api/webview-tag/'
    }

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;2017 GitHub Inc.<br>
      Licensed under the MIT license.
    HTML
  end
end
