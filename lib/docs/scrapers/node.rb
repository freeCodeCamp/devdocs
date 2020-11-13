module Docs
  class Node < UrlScraper
    self.name = 'Node.js'
    self.slug = 'node'
    self.type = 'node'
    self.links = {
      home: 'https://nodejs.org/',
      code: 'https://github.com/nodejs/node'
    }

    html_filters.push 'node/clean_html', 'node/entries', 'title'

    options[:title] = false
    options[:root_title] = 'Node.js'
    options[:container] = '#apicontent'
    options[:skip] = %w(index.html all.html documentation.html synopsis.html)

    options[:attribution] = <<-HTML
      &copy; Joyent, Inc. and other Node contributors<br>
      Licensed under the MIT License.<br>
      Node.js is a trademark of Joyent, Inc. and is used with its permission.<br>
      We are not endorsed by or affiliated with Joyent.
    HTML

    version do
      self.release = '14.15.0'
      self.base_url = 'https://nodejs.org/dist/latest-v14.x/docs/api/'
    end

    version '12 LTS' do
      self.release = '12.19.0'
      self.base_url = 'https://nodejs.org/dist/latest-v12.x/docs/api/'
    end

    version '10 LTS' do
      self.release = '10.16.3'
      self.base_url = 'https://nodejs.org/dist/latest-v10.x/docs/api/'
    end

    version '8 LTS' do
      self.release = '8.16.1'
      self.base_url = 'https://nodejs.org/dist/latest-v8.x/docs/api/'
    end

    version '6 LTS' do
      self.release = '6.14.4'
      self.base_url = 'https://nodejs.org/dist/latest-v6.x/docs/api/'
    end

    version '4 LTS' do
      self.release = '4.9.1'
      self.base_url = 'https://nodejs.org/dist/latest-v4.x/docs/api/'
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://nodejs.org/en/', opts)
      doc.at_css('#home-intro > .home-downloadblock:last-of-type > a')['data-version'][1..-1]
    end
  end
end
