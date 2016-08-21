module Docs
  class Meteor < UrlScraper
    class << self
      attr_accessor :guide_url
    end

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
      self.base_url = 'https://docs.meteor.com/'
      self.guide_url = 'https://guide.meteor.com/'
      self.initial_urls = [guide_url]
    end

    version '1.3' do
      self.release = '1.3.5'
      self.base_url = "https://docs.meteor.com/v#{self.release}/"
      self.guide_url = 'https://guide.meteor.com/v1.3/'
      self.initial_urls = [guide_url]
    end

    def guide_url
      @guide_url ||= URL.parse(self.class.guide_url)
    end

    private

    def process_url?(url)
      base_url.contains?(url) || guide_url.contains?(url)
    end

    def process_response(response)
      original_host = @base_url.host
      original_path = @base_url.path
      @base_url.host = response.effective_url.host
      @base_url.path = response.effective_url.path[/\A\/v[\d\.]+\//, 0] || '/'
      super
    ensure
      @base_url.host = original_host
      @base_url.path = original_path
    end
  end
end
