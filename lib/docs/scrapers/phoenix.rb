module Docs
  class Phoenix < UrlScraper
    self.type = 'elixir'
    self.release = '1.3.4'
    self.base_url = 'https://hexdocs.pm/'
    self.root_path = 'phoenix/Phoenix.html'
    self.initial_paths = %w(
      phoenix/api-reference.html
      ecto/api-reference.html
      phoenix_html/api-reference.html
      phoenix_pubsub/api-reference.html
      plug/api-reference.html)
    self.links = {
      home: 'http://www.phoenixframework.org',
      code: 'https://github.com/phoenixframework/phoenix'
    }

    html_filters.push 'elixir/clean_html', 'elixir/entries'

    options[:container] = '#content'

    options[:skip_patterns] = [/extra-api-reference/]
    options[:only_patterns] = [
      /\Aphoenix\//,
      /\Aecto\//,
      /\Aphoenix_pubsub\//,
      /\Aphoenix_html\//,
      /\Aplug\//
    ]

    options[:attribution] = -> (filter) {
      if filter.slug.start_with?('ecto')
        <<-HTML
          &copy; 2012 Plataformatec<br>
          Licensed under the Apache License, Version 2.0.
        HTML
      elsif filter.slug.start_with?('plug')
        <<-HTML
          &copy; 2013 Plataformatec<br>
          Licensed under the Apache License, Version 2.0.
        HTML
      else
        <<-HTML
          &copy; 2014 Chris McCord<br>
          Licensed under the MIT License.
        HTML
      end
    }

    def get_latest_version(opts)
      doc = fetch_doc('https://hexdocs.pm/phoenix/Phoenix.html', opts)
      doc.at_css('.sidebar-projectVersion').content.strip[1..-1]
    end
  end
end
