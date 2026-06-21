module Docs
  class Phoenix < UrlScraper
    include MultipleBaseUrls

    self.type = 'elixir'
    self.release = '1.8.8'
    self.root_path = 'overview.html'
    self.links = {
      home: 'http://www.phoenixframework.org',
      code: 'https://github.com/phoenixframework/phoenix'
    }

    self.base_urls = %w(
      https://phoenix.hexdocs.pm/
      https://ecto.hexdocs.pm/
      https://phoenix-html.hexdocs.pm/
      https://phoenix-live-view.hexdocs.pm/
      https://phoenix-pubsub.hexdocs.pm/
      https://plug.hexdocs.pm/
    )

    def initial_urls
      %w(
        https://phoenix.hexdocs.pm/overview.html
        https://ecto.hexdocs.pm/Ecto.html
        https://phoenix-html.hexdocs.pm/Phoenix.HTML.html
        https://phoenix-live-view.hexdocs.pm/welcome.html
        https://phoenix-pubsub.hexdocs.pm/Phoenix.PubSub.html
        https://plug.hexdocs.pm/readme.html
      )
    end

    html_filters.push 'elixir/clean_html', 'elixir/entries'

    options[:container] = '#content'

    # Filter docs for JS libraries, these use a different HTML layout.
    # e.g. https://phoenix.hexdocs.pm/js/ and https://phoenix-live-view.hexdocs.pm/1.2.0/js/
    #
    # Only match on `js` directories so we still catch normal pages like https://phoenix-live-view.hexdocs.pm/js-interop.html
    options[:skip_patterns] = [%r{(\A|/)js/}]

    options[:attribution] = -> (filter) {
      if filter.slug.start_with?('ecto')
        <<-HTML
          &copy; 2013 Plataformatec<br>
          &copy; 2020 Dashbit<br>
          Licensed under the Apache License, Version 2.0.
        HTML
      elsif filter.slug.start_with?('plug')
        <<-HTML
          &copy; 2013 Plataformatec<br>
          Licensed under the Apache License, Version 2.0.
        HTML
      elsif filter.slug.start_with?('phoenix_live_view')
        <<-HTML
          &copy; 2018 Chris McCord<br>
          Licensed under the MIT License.
        HTML
      else
        <<-HTML
          &copy; 2014 Chris McCord<br>
          Licensed under the MIT License.
        HTML
      end
    }

    def get_latest_version(opts)
      doc = fetch_doc('https://phoenix.hexdocs.pm/api-reference.html', opts)
      doc.at_css('.sidebar-projectVersion').content.strip[1..-1]
    end
  end
end
