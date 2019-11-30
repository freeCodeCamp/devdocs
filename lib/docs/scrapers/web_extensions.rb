module Docs
  class WebExtensions < UrlScraper
    self.name = 'Web Extensions'
    self.slug = 'web_extensions'
    self.type = 'simple'
    self.links = {
      home: 'https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions'
    }

    self.base_url = 'https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions'

    html_filters.push 'web_extensions/entries', 'web_extensions/clean_html'

    options[:skip_patterns] = [
      /\/contributors\.txt$/
    ]

    options[:attribution] = -> (filter) {
    <<-HTML
      <a href="#{filter.current_url}">#{filter.result()[:entries][0].name}</a> &copy; 2005-2021 Mozilla and individual contributors.<br>
      Licensed under the <a href="https://creativecommons.org/licenses/by-sa/2.5/">Creative Commons Attribution-ShareAlike license</a>
    HTML
    }

  end
end
