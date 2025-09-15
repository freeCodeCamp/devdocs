module Docs
  class Svelte < UrlScraper
    self.name = 'Svelte'
    self.slug = 'svelte'
    self.type = 'simple'
    self.root_path = '/'
    self.links = {
      home: 'https://svelte.dev/',
      code: 'https://github.com/sveltejs/svelte'
    }

    options[:root_title] = 'Svelte'

    # https://github.com/sveltejs/svelte/blob/master/LICENSE.md
    options[:attribution] = <<-HTML
      &copy; 2016–2025 Rich Harris and contributors<br>
      Licensed under the MIT License.
    HTML

    self.base_url = 'https://svelte.dev/docs/svelte/'
    html_filters.push 'svelte/entries', 'svelte/clean_html'

    version do
      self.release = '5.38.10'
    end

    version '4' do
      self.release = '4.2.1'
    end

    version '3' do
      self.release = '3.55.0'
    end

    def get_latest_version(opts)
      get_npm_version('svelte', opts)
    end
  end
end
