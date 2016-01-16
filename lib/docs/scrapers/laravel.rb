module Docs
  class Laravel < UrlScraper
    self.name = 'Laravel'
    self.slug = 'laravel'
    self.type = 'laravel'
    self.release = '5.2.0'
    self.base_url = 'https://laravel.com'
    self.root_path = '/api/5.2/index.html'
    self.initial_paths = %w(/docs/5.2/installation /api/5.2/classes.html)
    self.links = {
      home: 'https://laravel.com/',
      code: 'https://github.com/laravel/laravel'
    }

    html_filters.push 'laravel/entries', 'laravel/clean_html'

    options[:container] = ->(filter) {
      filter.subpath.start_with?('/api') ? '#content' : '.docs-wrapper'
    }

    options[:only_patterns] = [
      /\A\/api\/5\.2\//,
      /\A\/docs\/5\.2\//]

    options[:skip] = %w(
      /docs/5.2/quick
      /docs/5.2/releases
      /docs/5.2/artisan
      /docs/5.2/commands
      /api/5.2/.html
      /api/5.2/panel.html
      /api/5.2/namespaces.html
      /api/5.2/interfaces.html
      /api/5.2/traits.html
      /api/5.2/doc-index.html
      /api/5.2/Illuminate.html
      /api/5.2/search.html)

    options[:fix_urls] = ->(url) do
      url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.2/"
      url
    end

    options[:attribution] = <<-HTML
      &copy; Taylor Otwell<br>
      Licensed under the MIT License.
    HTML
  end
end
