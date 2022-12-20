# frozen_string_literal: true

module Docs
  class Qunit < UrlScraper
    self.name = 'QUnit'
    self.type = 'qunit'
    self.release = '2.19.3'
    self.base_url = 'https://api.qunitjs.com/'
    self.root_path = '/'
    self.links = {
      home: 'https://qunitjs.com/',
      code: 'https://github.com/qunitjs/qunit'
    }

    html_filters.push 'qunit/entries', 'qunit/clean_html'

    options[:trailing_slash] = false

    options[:container] = '.main'
    options[:skip_patterns] = [
      /deprecated/,
      /^QUnit$/,
      /^assert$/,
      /^callbacks$/,
      /^async$/,
      /^config$/,
      /^extension$/,
    ]

    options[:attribution] = <<-HTML
      &copy; OpenJS Foundation and contributors.<br>
      Licensed under the MIT license.
    HTML

    def get_latest_version(opts)
      get_npm_version('qunit', opts)
    end
  end
end
