module Docs
  class Clojure < UrlScraper
    self.type = 'clojure'
    self.root_path = 'api-index.html'

    html_filters.push 'clojure/entries', 'clojure/clean_html'

    options[:container] = '#content_view'
    options[:only_patterns] = [/\Aclojure\./]

    options[:attribution] = <<-HTML
      &copy; Rich Hickey<br>
      Licensed under the Eclipse Public License 1.0.
    HTML

    version '1.9' do
      self.release = '1.9'
      self.base_url = 'https://clojure.github.io/clojure/'
    end

    version '1.8' do
      self.release = '1.8'
      self.base_url = 'https://clojure.github.io/clojure/branch-clojure-1.8.0/'
    end

    version '1.7' do
      self.release = '1.7'
      self.base_url = 'https://clojure.github.io/clojure/branch-clojure-1.7.0/'
    end
  end
end
