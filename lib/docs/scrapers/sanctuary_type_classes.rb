module Docs

  class SanctuaryTypeClasses < Github
    self.name = "Sanctuary Type Classes"
    self.slug = "sanctuary_type_classes"
    self.type = "sanctuary_type_classes"
    self.release = "13.0.0"
    self.base_url = "https://github.com/sanctuary-js/sanctuary-type-classes/blob/v#{self.release}/README.md"
    self.links = {
      home: "https://github.com/sanctuary-js/sanctuary-type-classes",
      code: "https://github.com/sanctuary-js/sanctuary-type-classes",
    }

    html_filters.push "sanctuary_type_classes/entries", "sanctuary_type_classes/clean_html"

    options[:container] = '.markdown-body'
    options[:title] = "Sanctuary Type Classes"
    options[:trailing_slash] = false
    options[:attribution] = <<-HTML
      &copy; 2020 Sanctuary<br>
      &copy; 2016 Plaid Technologies, Inc.<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get-npm-version("sanctuary-type-classes", opts)
    end
  end
end
