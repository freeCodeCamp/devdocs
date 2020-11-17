module Docs
  class Jekyll < UrlScraper
    self.type = 'jekyll'
    self.release = '4.1.1'
    self.base_url = 'https://jekyllrb.com/docs/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://jekyllrb.com/',
      code: 'https://github.com/jekyll/jekyll'
    }

    html_filters.push 'jekyll/clean_html', 'jekyll/entries'

    options[:trailing_slash] = true
    options[:skip] = %w(sites/ upgrading/)
    options[:skip_patterns] = [
      /conduct/,
      /history/,
      /maintaining/,
      /contributing/,
    ]
    options[:replace_paths] = {
      'templates/' => 'liquid/'
    }

    options[:attribution] = <<-HTML
      &copy; 2020 Jekyll Core Team and contributors<br>
      Licensed under the MIT license.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://jekyllrb.com/docs/', opts)
      doc.at_css('.meta a').content[1..-1]
    end
  end
end
