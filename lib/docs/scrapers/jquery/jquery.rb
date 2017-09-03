module Docs
  class Jquery < UrlScraper
    self.abstract = true
    self.type = 'jquery'

    html_filters.push 'jquery/clean_html', 'title'

    options[:title] = false
    options[:container] = '#content'
    options[:trailing_slash] = false
    options[:skip_patterns] = [/deprecated/, /category\/version/]

    options[:attribution] = <<-HTML
      &copy; The jQuery Foundation and other contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
