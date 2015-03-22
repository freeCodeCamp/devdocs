module Docs
  class Meteor < UrlScraper
    self.type = 'meteor'
    self.version = '1.0.4'
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

    def request_one(url)
      stub_root_page if url == root_url.to_s
      super
    end

    def request_all(urls, &block)
      stub_root_page
      super
    end

    def stub_root_page
      response = Typhoeus::Response.new(
        effective_url: root_url.to_s,
        code: 200,
        headers: { 'Content-Type' => 'text/html' },
        body: get_root_page_body)

      Typhoeus.stub(root_url.to_s).and_return(response)
    end

    def get_root_page_body
      require 'capybara'
      Capybara.current_driver = :selenium
      Capybara.visit(root_url.to_s)
      Capybara.find('.body')['innerHTML']
    end
  end
end
