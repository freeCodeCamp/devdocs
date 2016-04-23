module Docs
  class Socketio < UrlScraper
    self.name = 'Socket.IO'
    self.slug = 'socketio'
    self.type = 'socketio'
    self.release = '1.4.5'
    self.base_url = 'http://socket.io/docs/'
    self.links = {
      home: 'http://socket.io/',
      code: 'https://github.com/socketio/socket.io'
    }

    html_filters.push 'socketio/clean_html', 'socketio/entries'

    options[:container] = '#content'
    options[:trailing_slash] = false
    options[:skip] = %w(faq)

    options[:attribution] = <<-HTML
      &copy; 2014&ndash;2015 Automattic<br>
      Licensed under the MIT License.
    HTML
  end
end
