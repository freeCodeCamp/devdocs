module Docs
  class Jekyll < UrlScraper
    self.type = 'jekyll'
    self.release = '3.6.2'
    self.base_url = 'https://jekyllrb.com/docs/'
    self.root_path = 'home/'
    self.links = {
      home: 'https://jekyllrb.com/',
      code: 'https://github.com/jekyll/jekyll'
    }

    html_filters.push 'jekyll/clean_html', 'jekyll/entries'

    options[:trailing_slash] = true
    options[:container] = 'article'
    options[:skip] = [
      '',
      '/'
    ]
    options[:skip_patterns] = [
      /conduct/,
      /history/,
      /maintaining/,
      /contributing/
    ]
    options[:attribution] = <<-HTML
      &copy; 2008&ndash;2017 Tom Preston-Werner and Jekyll contributors<br />
      Licensed under
        <a href="https://github.com/jekyll/jekyll/blob/master/LICENSE">
          the MIT license
        </a>
    HTML
  end
end
