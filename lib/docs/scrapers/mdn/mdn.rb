module Docs
  class Mdn < UrlScraper
    self.abstract = true
    self.type = 'mdn'
    self.links = {
      home: 'https://developer.mozilla.org',
      code: 'https://github.com/mdn/content'
    }

    html_filters.insert_before 'container', 'mdn/compat_tables' # needs access to <script type="application/json" id="hydration">
    html_filters.push 'mdn/clean_html'

    options[:container] = '#content > .main-page-content'
    options[:trailing_slash] = false

    options[:skip_link] = ->(link) {
      link['title'].try(:include?, 'not yet been written'.freeze) && !link['href'].try(:include?, 'transform-function'.freeze)
    }

    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2023 MDN contributors.<br>
      Licensed under the Creative Commons Attribution-ShareAlike License v2.5 or later.
    HTML

    def get_latest_version(opts)
      get_latest_github_commit_date('mdn', 'content', opts)
    end
  end
end
