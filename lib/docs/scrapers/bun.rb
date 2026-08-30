module Docs
  class Bun < UrlScraper
    self.name = 'Bun'
    self.type = 'simple'
    self.slug = 'bun'
    self.links = {
      home: 'https://bun.com/',
      code: 'https://github.com/oven-sh/bun'
    }
    self.release = '1.4.0'
    self.base_url = "https://bun.com/"
    self.root_path = 'docs/installation'
    self.initial_paths = ['guides']

    html_filters.push 'bun/clean_html', 'bun/entries'

    # https://bun.com/docs/project/licensing
    options[:attribution] = <<-HTML
      &copy; bun.com, oven-sh, Jarred Sumner<br>
      Licensed under the MIT License.
    HTML

    options[:download_images] = false
    options[:only_patterns] = [/\Adocs\//, /\Aguides/]
    options[:skip_patterns] = [/\Adocs\/project/, /\Adocs\/feedback/]
    options[:fix_urls] = ->(url) do
      url.sub! %r{.md$}, ''
      url
    end

    version do
      self.release = '1.4.0'
    end

    version '1.3' do
      self.release = '1.3.12'
    end

    def get_latest_version(opts)
      get_latest_github_release('oven-sh', 'bun', opts)[5..]
    end
  end
end
