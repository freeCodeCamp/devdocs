module Docs
  class Bun < UrlScraper
    self.name = 'Bun'
    self.type = 'simple'
    self.slug = 'bun'
    self.links = {
      home: 'https://leafletjs.com/',
      code: 'https://github.com/oven-sh/bun'
    }
    self.release = '1.3.5'
    self.base_url = "https://bun.com/docs/"
    self.root_path = 'installation'

    html_filters.push 'bun/clean_html', 'bun/entries'

    # https://bun.com/docs/project/licensing
    options[:attribution] = <<-HTML
      &copy; bun.com, oven-sh, Jarred Sumner<br>
      Licensed under the MIT License.
    HTML

    options[:download_images] = false
    options[:skip_patterns] = [/^project/, /^feedback/]
    options[:fix_urls] = ->(url) do
      url.sub! %r{.md$}, ''
      url
    end

    def get_latest_version(opts)
      get_latest_github_release('oven-sh', 'bun', opts)[5..]
    end
  end
end
