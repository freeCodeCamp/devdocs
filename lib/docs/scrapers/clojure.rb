module Docs
  class Clojure < UrlScraper
    self.type = 'clojure'
    self.root_path = 'api-index.html'
    self.links = {
      home: 'https://clojure.org',
      code: 'https://github.com/clojure/clojure'
    }

    html_filters.push 'clojure/entries', 'clojure/clean_html'

    options[:container] = '#content_view'
    options[:only_patterns] = [/\Aclojure\./]

    options[:attribution] = <<-HTML
      &copy; Rich Hickey<br>
      Licensed under the Eclipse Public License 1.0.
    HTML

    version '1.11' do
      self.release = '1.11'
      self.base_url = 'https://clojure.github.io/clojure/'
    end

    version '1.10' do
      self.release = '1.10.3'
      self.base_url = "https://clojure.github.io/clojure/branch-clojure-#{self.release}/"
    end

    version '1.9' do
      self.release = '1.9 (legacy)'
      self.base_url = 'https://clojure.github.io/clojure/branch-clojure-1.9.0/'
    end

    version '1.8' do
      self.release = '1.8 (legacy)'
      self.base_url = 'https://clojure.github.io/clojure/branch-clojure-1.8.0/'
    end

    version '1.7' do
      self.release = '1.7 (legacy)'
      self.base_url = 'https://clojure.github.io/clojure/branch-clojure-1.7.0/'
    end

    def get_latest_version(opts)
      doc = fetch_doc('http://clojure.github.io/clojure/index.html', opts)
      doc.at_css('#header-version').content[1..-1]
    end
  end
end
