module Docs
  class Meteor < UrlScraper
    include MultipleBaseUrls

    self.type = 'meteor'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://www.meteor.com/',
      code: 'https://github.com/meteor/meteor/'
    }

    html_filters.push 'meteor/entries', 'meteor/clean_html'

    options[:skip_patterns] = [/\Av\d/]
    options[:skip] = %w(
      CONTRIBUTING.html
      CHANGELOG.html
      using-packages.html
      writing-packages.html
    )

    options[:attribution] = <<-HTML
      &copy; 2011&ndash;2016 Meteor Development Group<br>
      Licensed under the MIT License.
    HTML

    version '1.4' do
      self.release = '1.4.0'
      self.base_urls = ['https://docs.meteor.com/', 'https://guide.meteor.com/']
    end

    version '1.3' do
      self.release = '1.3.5'
      self.base_urls = ["https://docs.meteor.com/v#{self.release}/", 'https://guide.meteor.com/v1.3/']
    end
  end
end
