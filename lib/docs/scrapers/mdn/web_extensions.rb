module Docs
  class WebExtensions < Mdn
    # release = '2022-04-28'
    self.name = 'Web Extensions'
    self.slug = 'web_extensions'
    self.links = {
      home: 'https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions'
    }

    self.base_url = 'https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions'

    html_filters.push 'web_extensions/entries', 'web_extensions/clean_html'

    options[:skip_patterns] = [
      /\/contributors\.txt$/
    ]

  end
end
