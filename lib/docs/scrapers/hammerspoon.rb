module Docs
  class Hammerspoon < UrlScraper
    self.type = 'hammerspoon'
    self.root_path = ''
    self.links = {
      home: 'https://www.hammerspoon.org',
      code: 'https://github.com/Hammerspoon/hammerspoon'
    }
    self.base_url = 'https://www.hammerspoon.org/docs/'
    self.release = '0.9.100'

    html_filters.push 'hammerspoon/clean_html', 'hammerspoon/entries'

    # links with no content will still render a page, this is an error in the docs
    # (see: https://github.com/Hammerspoon/hammerspoon/pull/3579)
    options[:skip] = ['module.lp/matrix.md']
    options[:skip_patterns] = [
      /LuaSkin/,
    ]

    # Hammerspoon docs don't have a license (MIT specified in the hammerspoon repo)
    # https://github.com/Hammerspoon/hammerspoon/blob/master/LICENSE
    options[:attribution] = <<-HTML
      &copy; 2014–2017 Hammerspoon contributors<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('Hammerspoon', 'hammerspoon', opts)
    end

  end
end
