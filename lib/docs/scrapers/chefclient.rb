module Docs
  class Chefclient < UrlScraper
    self.name = 'Chef Client'
    self.slug = 'chefclient'
    self.type = 'chefclient'
    self.version = '12.5'
    self.base_url = "https://docs.chef.io/release/#{version.sub '.', '-'}/"
    self.links = {
      home: 'https://www.chef.io/',
      docs: 'https://docs.chef.io/'
    }

    html_filters.push 'chefclient/entries', 'chefclient/clean_html'

    options[:fix_urls] = ->(url) do
      url.remove! %r{/release/[0-9\-+]/}
      url
    end

    options[:skip_patterns]  = [/_images\//]
    options[:trailing_slash] = false

    options[:attribution] = <<-HTML
      &copy; 2015 Chef Software, Inc.<br>
      Creative Commons Attribution 3.0 Unported License.
    HTML
  end
end
