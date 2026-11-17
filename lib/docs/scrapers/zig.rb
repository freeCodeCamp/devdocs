module Docs
  class Zig < UrlScraper
    self.name = 'Zig'
    self.type = 'simple'
    self.release = '0.16.0'
    self.base_url = "https://ziglang.org/documentation/#{self.release}/"
    self.links = {
      home: 'https://ziglang.org/',
      code: 'https://codeberg.org/ziglang/zig'
    }

    html_filters.push 'zig/entries', 'zig/clean_html'

    options[:follow_links] = false
    options[:attribution] = <<-HTML
      &copy; 2015–2026, Zig contributors<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      tags = get_codeberg_tags('ziglang', 'zig', opts)
      tags[0]['name']
    end
  end
end
