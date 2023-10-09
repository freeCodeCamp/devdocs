module Docs
  class Svelte < UrlScraper
    self.name = 'Svelte'
    self.slug = 'svelte'
    self.type = 'simple'
    self.links = {
      home: 'https://svelte.dev/',
      code: 'https://github.com/sveltejs/svelte'
    }

    self.root_path = 'introduction'
    options[:root_title] = 'Svelte'

    # https://github.com/sveltejs/svelte/blob/master/LICENSE.md
    options[:attribution] = <<-HTML
      &copy; 2016–2023 Rich Harris and contributors<br>
      Licensed under the MIT License.
    HTML

    options[:skip] = %w(team.html plugins/)

    self.base_url = 'https://svelte.dev/docs/'
    html_filters.push 'svelte/entries', 'svelte/clean_html'
    
    version do
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
