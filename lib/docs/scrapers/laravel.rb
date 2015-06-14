module Docs
  class Laravel < UrlScraper
    self.name = 'Laravel'
    self.slug = 'laravel'
    self.type = 'laravel'
    self.version = '5.1.1'
    self.base_url = 'http://laravel.com'
    self.root_path = '/api/5.1/index.html'
    self.initial_paths = %w(/docs/5.1/installation /api/5.1/classes.html)
    self.links = {
      home: 'http://laravel.com/',
      code: 'https://github.com/laravel/laravel'
    }

    html_filters.push 'laravel/entries', 'laravel/clean_html'

    options[:container] = ->(filter) {
      filter.subpath.start_with?('/api') ? '#content' : '.docs-wrapper'
    }

    options[:only_patterns] = [
      /\A\/api\/5\.1\//,
      /\A\/docs\/5\.1\//]

    options[:skip] = %w(
      /docs/5.1/quick
      /docs/5.1/releases
      /docs/5.1/artisan
      /docs/5.1/commands
      /api/5.1/panel.html
      /api/5.1/namespaces.html
      /api/5.1/interfaces.html
      /api/5.1/traits.html
      /api/5.1/doc-index.html
      /api/5.1/Illuminate.html
      /api/5.1/search.html)

    options[:fix_urls] = ->(url) do
      url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.1/"
      url
    end

    options[:attribution] = <<-HTML
      &copy; Taylor Otwell<br>
      Licensed under the MIT License.
    HTML
  end
end
