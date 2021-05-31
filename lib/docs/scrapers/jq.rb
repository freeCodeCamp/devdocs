module Docs
  class Jq < UrlScraper
    self.name = 'jq'
    self.slug = 'jq'
    self.type = 'jq'
    self.release = '1.6'
    self.links = {
      home: 'https://stedolan.github.io/jq/'
    }

    self.base_url = "https://stedolan.github.io/jq/manual/v#{self.release}/index.html"

    html_filters.push 'jq/entries', 'jq/clean_html'

    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2012 Stephen Dolan<br>
      Licensed under the <a href="https://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0 license</a>
    HTML

    def get_latest_version(opts)
      get_latest_github_release('stedolan', 'jq', opts).split('-')[1]
    end

  end
end
