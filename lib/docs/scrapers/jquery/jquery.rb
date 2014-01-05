module Docs
  class Jquery < UrlScraper
    self.abstract = true
    self.type = 'jquery'

    html_filters.push 'jquery/clean_html', 'title'
    text_filters.push 'jquery/clean_urls'

    options[:title] = false
    options[:container] = '#content'
    options[:trailing_slash] = false
    options[:skip_patterns] = [/category/]

    options[:attribution] = <<-HTML
      &copy; 2014 The jQuery Foundation<br>
      Licensed under the MIT License.
    HTML
  end
end
