module Docs
  class Marionette < UrlScraper
    self.name = 'Marionette.js'
    self.slug = 'marionette'
    self.type = 'marionette'
    self.version = '2.3.0'
    self.base_url = 'http://marionettejs.com/docs/'
    self.root_path = 'current'

    html_filters.push 'marionette/clean_html', 'marionette/entries'

    options[:container] = '#content'

    options[:skip] = %w(/readme.html)
    options[:skip_patterns] = [/\A\/v\d/]

    options[:fix_urls] = ->(url) do
      url.sub! %r{marionette([^\/#\?]*)\.md}, 'marionette\1'
      url
    end

    options[:attribution] = <<-HTML
      &copy; 2014 Muted Solutions, LLC<br>
      Licensed under the MIT License.
    HTML
  end
end
