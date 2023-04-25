module Docs
  class Vueuse < UrlScraper
    self.name = 'VueUse'
    self.slug = 'vueuse'
    self.type = 'vueuse'
    self.links = {
      home: 'https://vueuse.org/',
      code: 'https://github.com/vueuse/vueuse'
    }

    options[:skip] = %w(add-ons contributing ecosystem)
    options[:skip_patterns] = [/index$/]
    options[:fix_urls] = ->(url) do
      url.sub! %r{/index$}, ''
      url.sub! 'vueuse.org/on', 'vueuse.org/core/on'
      url.sub! 'vueuse.org/use', 'vueuse.org/core/use'
      url
    end

    options[:attribution] = <<-HTML
      &copy; 2019-present Anthony Fu<br>
      Licensed under the MIT License.
    HTML

    self.release = '10.1.0'
    self.base_url = 'https://vueuse.org/'
    self.initial_paths = %w(functions.html)
    html_filters.push 'vueuse/entries', 'vite/clean_html', 'vueuse/clean_html'

    def get_latest_version(opts)
      get_npm_version('@vueuse/core', opts)
    end
  end
end
