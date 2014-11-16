module Docs
  class Laravel < UrlScraper
    self.name = 'Laravel'
    self.slug = 'laravel'
    self.type = 'laravel'
    self.version = '4.2.11'
    self.base_url = 'http://laravel.com'
    self.root_path = '/docs/4.2/introduction'
    self.initial_paths = %w(/api/4.2/classes.html)

    html_filters.push 'laravel/entries', 'laravel/clean_html'

    options[:container] = ->(filter) {
      filter.subpath.start_with?('/api') ? nil : '#documentation > article'
    }

    options[:only_patterns] = [
      /\A\/api\/4\.2\//,
      /\A\/docs\/4\.2\//]

    options[:skip] = %w(
      /docs/4.2/quick
      /docs/4.2/releases
      /docs/4.2/upgrade
      /docs/4.2/artisan
      /docs/4.2/commands
      /api/4.2/panel.html
      /api/4.2/namespaces.html
      /api/4.2/interfaces.html
      /api/4.2/traits.html
      /api/4.2/doc-index.html
      /api/4.2/Illuminate.html)

    options[:fix_urls] = ->(url) do
      url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/4.2/"
      url
    end

    options[:attribution] = <<-HTML
      &copy; Taylor Otwell<br>
      Licensed under the MIT License.
    HTML
  end
end
