module Docs
  class Immutablejs < UrlScraper
    self.name = "ImmutableJS"
    self.type = "immutablejs"
    self.release = "3.8.1"
    self.base_url = "https://facebook.github.io/immutable-js/docs/"


    #
    # Replacins core html filters with our own, so we can handle fragments in
    #
    html_filters.replace 'internal_urls', 'immutablejs/internal_urls'
    html_filters.replace 'normalize_paths', 'immutablejs/normalize_paths'

    html_filters.push  'immutablejs/clean_html', 'immutablejs/entries'


    options[:attribution] = <<-HTML
      This documentation is generated from <a href="https://github.com/facebook/immutable-js/blob/master/type-definitions/Immutable.d.ts">Immutable.d.ts</a>.
      Pull requests and <a href="https://github.com/facebook/immutable-js/issues">Issues</a> welcome.
    HTML

    stub(/.*/) do |url|
      #
      # Reuse capybara sessions, since we scrape all pages..
      # by visiting 'about:blank' we reset the oldest session.
      #
      @capybara ||= load_capybara_selenium
      @capybara.visit 'about:blank'
      @capybara.visit url

      @capybara.execute_script 'return document.querySelector(".docContents").innerHTML'
    end



  end
end
