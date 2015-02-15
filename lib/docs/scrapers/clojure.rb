module Docs
  class Clojure < UrlScraper
    self.type = 'clojure'
    self.version = '1.6'
    self.base_url = 'http://clojure.github.io/clojure/'
    self.root_path = 'api-index.html'

    html_filters.push 'clojure/entries', 'clojure/clean_html'

    options[:container] = '#content_view'
    options[:only_patterns] = [/\Aclojure\./]

    options[:attribution] = <<-HTML
      &copy; Rich Hickey<br>
      Licensed under the Eclipse Public License 1.0.
    HTML
  end
end
