module Docs
  class Electron < UrlScraper
    self.type = 'simple'
    self.base_url = 'https://www.electronjs.org/docs/latest'
    self.release = '20.0.0'
    self.links = {
      home: 'https://www.electronjs.org/',
      code: 'https://github.com/electron/electron'
    }

    html_filters.push 'electron/clean_html', 'electron/entries'

    options[:trailing_slash] = false
    options[:container] = 'main'
    options[:skip] = %w(guides development tutorial versions all)
    options[:skip_patterns] = [
      /\/history\z/,
    ]
    options[:replace_paths] = {
      'api/web-view-tag' => 'api/webview-tag'
    }

    options[:attribution] = <<-HTML
      &copy; GitHub Inc.<br>
      Licensed under the MIT license.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://www.electronjs.org/releases/stable', opts)
      doc.at_css('.release-card__metadata>a')['href'].gsub!(/[a-zA-Z\/:]/, '')[1..-1]
    end
  end
end
