module Docs
  class Screeps < UrlScraper
    self.type = 'screeps'
    self.release = '3.0.0'
    self.base_url = 'https://docs.screeps.com/'
    self.links = {
      home: 'https://screeps.com/',
      code: 'https://github.com/screeps/screeps'
    }

    html_filters.push 'screeps/clean_html', 'screeps/entries'

    # Remove all pages that may promote buying the game (and other useless pages)
    # The api reference is linked as both "api/" and "api", so one needs to be excluded to prevent a duplicate page
    options[:skip] = %w(api contributed/rules.html privacy-policy.html tos.html subscription.html)

    options[:attribution] = <<-HTML
      &copy; 2018 Screeps<br>
      Licensed under the Creative Commons Attribution 4.0 International Public License.
    HTML
  end
end
