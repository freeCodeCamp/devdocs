module Docs
  class Htmx < UrlScraper
    self.name = 'htmx'
    self.type = 'simple'
    self.slug = 'htmx'
    self.links = {
      home: 'https://htmx.org/',
      code: 'https://github.com/bigskysoftware/htmx'
    }
    self.initial_paths = %w(reference/)

    html_filters.push 'htmx/entries', 'htmx/clean_html'

    options[:trailing_slash] = true
    options[:container] = '.content'
    options[:download_images] = false
    options[:skip_patterns] = [
      /\Aessays/,
      /\Aexamples/,
      /\Amigration-guide/,
      /\Aposts/,
    ]

    # https://github.com/bigskysoftware/htmx/blob/master/LICENSE
    options[:attribution] = <<-HTML
    Licensed under the Zero-Clause BSD License.
    HTML

    # htmx 4 has its own site, built with Astro instead of Zola, with one page
    # per attribute/event/header/... instead of a single reference page.
    version do
      self.release = '4.0.0'
      self.base_url = "https://four.htmx.org/"
      self.root_path = 'docs/'
      self.initial_paths = %w(reference/ extensions/ docs/quirks/)

      html_filters.replace 'htmx/entries', 'htmx/entries_v4'
      html_filters.replace 'htmx/clean_html', 'htmx/clean_html_v4'

      # the page itself, next to the "on this page" <aside>
      options[:container] = 'main#content-main-content > div > div'
      # the rest of the site is essays, announcements, interviews, memes, ...
      options[:only_patterns] = [/\A(docs|reference|extensions)\//]

      # htmx 4 is published under the "next" dist-tag, "latest" is still 2.x
      def get_latest_version(opts)
        get_npm_version('htmx.org', opts, 'next')
      end
    end

    version '2' do
      self.release = '2.0.10'
      self.base_url = "https://htmx.org/"
    end

    version '1' do
      self.release = '1.9.12'
      self.base_url = "https://v1.htmx.org/"
    end

    def get_latest_version(opts)
      get_npm_version('htmx.org', opts)
    end
  end
end
