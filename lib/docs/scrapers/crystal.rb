module Docs
  class Crystal < UrlScraper
    self.name = "Crystal"
    self.type = "crystal"
    self.base_url = "https://github.com/crystal-lang/crystal-book"
    self.initial_paths = %w(/blob/master/SUMMARY.md)
    self.links = {
      home: "https://crystal-lang.org/",
      code: "https://github.com/crystal-lang/crystal"
    }

    html_filters.push "crystal/clean_html", "crystal/entries"

    options[:container] = ".entry-content"
    options[:only_patterns] = [/\/blob\/master\/.*\.md/]
    options[:skip] = %w(/blob/master/README.md)

    options[:attribution] = <<-HTML
      <a href="http://creativecommons.org/publicdomain/zero/1.0/">CC0</a>
    HTML
  end
end
