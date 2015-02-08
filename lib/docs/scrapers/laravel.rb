module Docs
  class Laravel < UrlScraper
    self.name = 'Laravel'
    self.slug = 'laravel'
    self.type = 'laravel'
    self.version = '5.0.0'
    self.base_url = 'http://laravel.com'
    self.root_path = '/api/5.0/index.html'
    self.initial_paths = %w(/docs/5.0/installation /api/5.0/classes.html)

    html_filters.push 'laravel/entries', 'laravel/clean_html'

    options[:container] = ->(filter) {
      filter.subpath.start_with?('/api') ? '#content' : '.docs-wrapper'
    }

    options[:only_patterns] = [
      /\A\/api\/5\.0\//,
      /\A\/docs\/5\.0\//]

    options[:skip] = %w(
      /docs/5.0/quick
      /docs/5.0/releases
      /docs/5.0/artisan
      /docs/5.0/commands
      /api/5.0/panel.html
      /api/5.0/namespaces.html
      /api/5.0/interfaces.html
      /api/5.0/traits.html
      /api/5.0/doc-index.html
      /api/5.0/Illuminate.html
      /api/5.0/search.html)

    options[:fix_urls] = ->(url) do
      url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.0/"
      url
    end

    options[:attribution] = <<-HTML
      &copy; Taylor Otwell<br>
      Licensed under the MIT License.
    HTML
  end
end
