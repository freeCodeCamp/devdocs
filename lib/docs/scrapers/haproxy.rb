module Docs
  class Haproxy < UrlScraper
    self.name = 'HAProxy'
    self.type = 'haproxy'
    self.root_path = 'intro.html'
    self.initial_paths = %w(intro.html configuration.html management.html)
    self.links = {
      home: 'https://www.haproxy.org/',
      code: 'https://github.com/haproxy/haproxy'
    }

    html_filters.push 'haproxy/clean_html', 'haproxy/entries'

    options[:container] = '#page-wrapper > .row > .col-lg-12'

    options[:follow_links] = false

    options[:attribution] = <<-HTML
      &copy; 2023 Willy Tarreau, HAProxy contributors<br>
      Licensed under the GNU General Public License version 2.
    HTML

    version '2.8' do
      self.release = '2.8.0'
      self.base_url = "https://docs.haproxy.org/#{self.version}/"
    end

    version '2.7' do
      self.release = '2.7.0'
      self.base_url = "https://docs.haproxy.org/#{self.version}/"
    end

    version '2.6' do
      self.release = '2.6.5'
      self.base_url = "https://docs.haproxy.org/#{self.version}/"
    end

    version '2.5' do
      self.release = '2.5.8'
      self.base_url = "https://docs.haproxy.org/#{self.version}/"
    end

    version '2.4' do
      self.release = '2.4.18'
      self.base_url = "https://docs.haproxy.org/#{self.version}/"
    end

    version '2.3' do
      self.release = '2.3.0'
      self.base_url = "http://cbonte.github.io/haproxy-dconv/#{self.version}/"
    end

    version '2.2' do
      self.release = '2.2.5'
      self.base_url = "http://cbonte.github.io/haproxy-dconv/#{self.version}/"
    end

    version '2.1' do
      self.release = '2.1.10'
      self.base_url = "http://cbonte.github.io/haproxy-dconv/#{self.version}/"
    end

    version '2.0' do
      self.release = '2.0.19'
      self.base_url = "http://cbonte.github.io/haproxy-dconv/#{self.version}/"
    end

    version '1.9' do
      self.release = '1.9.16'
      self.base_url = "http://cbonte.github.io/haproxy-dconv/#{self.version}/"
    end

    version '1.8' do
      self.release = '1.8.27'
      self.base_url = "http://cbonte.github.io/haproxy-dconv/#{self.version}/"
    end

    version '1.7' do
      self.release = '1.7.12'
      self.base_url = "http://cbonte.github.io/haproxy-dconv/#{self.version}/"
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://www.haproxy.org', opts)
      doc.at_css('table[cols=6]').at_css('tr:not(:first-child) > td:first-child:not(:contains("dev"))').content
    end
  end
end
