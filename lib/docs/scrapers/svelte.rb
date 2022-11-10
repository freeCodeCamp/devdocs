module Docs
  class Svelte < UrlScraper
    self.name = 'Svelte'
    self.slug = 'svelte'
    self.type = 'simple'
    self.links = {
      home: 'https://svelte.dev/',
      code: 'https://github.com/sveltejs/svelte'
    }

    options[:root_title] = 'Svelte'

    options[:attribution] = <<-HTML
      &copy; 2016–2022 Rich Harris and contributors<br>
      Licensed under the MIT License.
    HTML

    options[:skip] = %w(team.html plugins/)

    self.release = '3.53.0'
    self.base_url = 'https://svelte.dev/docs'
    html_filters.push 'svelte/entries', 'svelte/clean_html'

    def get_latest_version(opts)
      get_npm_version('svelte', opts)
    end
  end
end
