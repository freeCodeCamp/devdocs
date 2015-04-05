module Docs
  class Meteor < UrlScraper
    include StubRootPage

    self.type = 'meteor'
    self.version = '1.1.0'
    self.base_url = 'http://docs.meteor.com'
    self.root_path = '/#/full/'
    self.links = {
      home: 'https://www.meteor.com/',
      code: 'https://github.com/meteor/meteor/'
    }

    html_filters.push 'meteor/entries', 'meteor/clean_html', 'title'

    options[:title] = 'Meteor'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2011&ndash;2015 Meteor Development Group<br>
      Licensed under the MIT License.
    HTML

    private

    def root_page_body
      require 'capybara'
      Capybara.current_driver = :selenium
      Capybara.visit(root_url.to_s)
      Capybara.find('.body')['innerHTML']
    end
  end
end
