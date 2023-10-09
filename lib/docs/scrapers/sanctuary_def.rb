module Docs

  class SanctuaryDef < Github
    self.name = "Sanctuary Def"
    self.slug = "sanctuary_def"
    self.type = "sanctuary_def"
    self.release = "0.22.0"
    self.base_url = "https://github.com/sanctuary-js/sanctuary-def/blob/v#{self.release}/README.md"
    self.links = {
      home: "https://github.com/sanctuary-js/sanctuary-def",
      code: "https://github.com/sanctuary-js/sanctuary-def",
    }

    html_filters.push "sanctuary_def/entries", "sanctuary_def/clean_html"

    options[:container] = '.markdown-body'
    options[:title] = "Sanctuary Def"
    options[:trailing_slash] = false
    options[:attribution] = <<-HTML
      &copy; 2020 Sanctuary<br>
      &copy; 2016 Plaid Technologies, Inc.<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_npm_version("sanctuary-def", opts)
    end
  end
end
