module Docs

  class Fluture < Github
    self.name = "Fluture"
    self.slug = "fluture"
    self.type = "fluture"
    self.release = "14.0.0"
    self.base_url = "https://github.com/fluture-js/Fluture/blob/#{self.release}/README.md"
    self.links = {
      home: "https://github.com/fluture-js/Fluture",
      code: "https://github.com/fluture-js/Fluture",
    }

    html_filters.push "fluture/entries", "fluture/clean_html"

    options[:skip] = %w[middleware.gif]
    options[:container] = '.markdown-body'
    options[:title] = "Fluture"
    options[:trailing_slash] = false
    options[:attribution] = <<-HTML
      &copy; 2020 Aldwin Vlasblom<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_npm_version("fluture", opts)
    end
  end
end
