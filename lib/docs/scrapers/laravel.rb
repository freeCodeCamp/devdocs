module Docs
  class Laravel < UrlScraper
    self.name = 'Laravel'
    self.slug = 'laravel'
    self.type = 'laravel'
    self.version = '4.2.0'
    self.base_url = 'http://laravel.com'
    self.root_path = '/docs/introduction'
    self.initial_paths = %w(/api/4.2/namespaces.html)

    html_filters.push 'laravel/entries', 'laravel/clean_html'

    options[:container] = ->(filter) {
      filter.subpath.start_with?('/api') ? nil : '#documentation > article'
    }

    options[:only_patterns] = [
      /\A\/api\/4\.2\//,
      /\A\/docs\//]

    options[:skip] = %w(
      /docs/quick
      /docs/releases
      /docs/upgrade
      /docs/artisan
      /docs/commands
      /api/4.2/panel.html
      /api/4.2/classes.html
      /api/4.2/interfaces.html
      /api/4.2/traits.html
      /api/4.2/doc-index.html
      /api/4.2/Illuminate.html)

    options[:attribution] = <<-HTML
      &copy; Taylor Otwell<br>
      Licensed under the MIT License.
    HTML
  end
end
