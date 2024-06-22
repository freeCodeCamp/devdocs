module Docs
  class Astro < UrlScraper
    self.name = 'Astro'
    self.slug = 'astro'
    self.type = 'simple'
    self.links = {
      home: 'https://docs.astro.build/',
      code: 'https://github.com/withastro/astro'
    }

    # https://github.com/withastro/astro/blob/main/LICENSE
    options[:attribution] = <<-HTML
      &copy; 2021 Fred K. Schott<br>
      Licensed under the MIT License.
    HTML

    options[:skip_patterns] = [/tutorial/]

    self.release = '3.2.0'
    self.base_url = 'https://docs.astro.build/en/'
    self.initial_paths = %w(getting-started/)

    html_filters.push 'astro/entries', 'astro/clean_html'

    def get_latest_version(opts)
      get_npm_version('astro', opts)
    end

    private

    def parse(response)
      if response.url == self.base_url
        # root_page is a redirect
        response.body.gsub! %r{.*}, '<body><article><section><h1>Astro</h1><p> Astro is a website build tool for the modern web — powerful developer experience meets lightweight output.</p></section></article></body>'
      end
      super
    end

  end
end
