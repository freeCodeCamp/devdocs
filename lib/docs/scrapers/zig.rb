module Docs
  class Zig < UrlScraper
    self.name = 'Zig'
    self.type = 'simple'
    self.release = 'master'
    self.base_url = 'https://ziglang.org/documentation/master/'
    self.links = {
      home: 'https://ziglang.org/',
      code: 'https://github.com/ziglang/zig'
    }

    html_filters.push 'zig/entries', 'zig/clean_html'

    options[:follow_links] = false
    options[:attribution] = <<-HTML
      &copy; 2015–2022, Zig contributors
    HTML

    def get_latest_version(opts)
      tags = get_github_tags('ziglang', 'zig', opts)
      tags[0]['name']
    end
  end
end
