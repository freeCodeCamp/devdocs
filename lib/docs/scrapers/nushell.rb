module Docs

  class Nushell < UrlScraper
    include MultipleBaseUrls

    self.name = "Nushell"
    self.slug = "nushell"
    self.type = "nushell"
    self.release = "0.85.0"
    self.links = {
      home: "https://www.nushell.sh/",
      code: "https://github.com/nushell/nushell",
    }

    html_filters.push "nushell/clean_html", "nushell/entries", "nushell/fix_links"

    options[:container] = '.theme-container'
    options[:follow_links] = true
    options[:title] = "Nushell"
    options[:attribution] = <<-HTML
      Copyright &copy; 2019–2023 The Nushell Project Developers
      Licensed under the MIT License.
    HTML

    # latest version has a special URL that does not include the version identifier
    version do
      self.base_urls = [
        "https://www.nushell.sh/book/",
        "https://www.nushell.sh/commands/"
      ]
    end

    def get_latest_version(opts)
      get_latest_github_release('nushell', 'nushell', opts)
    end

  end

end
