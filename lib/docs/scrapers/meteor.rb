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

    options[:fix_urls] = ->(url) {
      url.sub! %r{\Ahttps://docs\.meteor\.com/(v[\d\.]*\/)?api/blaze\.html}, 'http://blazejs.org/api/blaze.html'
      url.sub! %r{\Ahttps://docs\.meteor\.com/(v[\d\.]*\/)?api/templates\.html}, 'http://blazejs.org/api/templates.html'
      url
    }

    options[:attribution] = <<-HTML
      &copy; 2011&ndash;2017 Meteor Development Group, Inc.<br>
      Licensed under the MIT License.
    HTML

    version '1.5' do
      self.release = '1.5.2'
      self.base_urls = ['https://docs.meteor.com/', 'https://guide.meteor.com/', 'http://blazejs.org/']
    end

    version '1.4' do
      self.release = '1.4.4'
      self.base_urls = ['https://guide.meteor.com/', "https://docs.meteor.com/v#{self.release}/", 'http://blazejs.org/']
    end

    version '1.3' do
      self.release = '1.3.5'
      self.base_urls = ['https://guide.meteor.com/v1.3/', "https://docs.meteor.com/v#{self.release}/"]
      options[:fix_urls] = nil
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://docs.meteor.com/#/full/', opts)
      doc.at_css('select.version-select > option').content
    end
  end
end
