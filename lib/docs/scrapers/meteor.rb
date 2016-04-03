module Docs
  class Meteor < UrlScraper
    self.type = 'meteor'
    self.release = '1.3.0'
    self.base_url = 'http://guide.meteor.com/v1.3/'
    self.initial_paths = %w(guide)
    self.links = {
      home: 'https://www.meteor.com/',
      code: 'https://github.com/meteor/meteor/'
    }

    html_filters.push 'meteor/entries', 'meteor/clean_html'

    options[:skip_links] = ->(filter) { filter.root_page? }

    options[:attribution] = <<-HTML
      &copy; 2011&ndash;2016 Meteor Development Group<br>
      Licensed under the MIT License.
    HTML

    stub '' do
      require 'capybara/dsl'
      Capybara.current_driver = :selenium
      Capybara.run_server = false
      Capybara.app_host = 'https://docs.meteor.com'
      Capybara.visit('/#/full/')
      Capybara.find('.body')['innerHTML']
    end

    stub 'guide' do
      request_one(url_for('index.html')).body
    end

    options[:replace_paths] = { 'index.html' => 'guide' }
  end
end
