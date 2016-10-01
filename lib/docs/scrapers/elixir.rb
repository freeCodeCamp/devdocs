module Docs
  class Elixir < UrlScraper
    include MultipleBaseUrls

    self.name = 'Elixir'
    self.type = 'elixir'
    self.release = '1.3.3'
    self.base_urls = ['http://elixir-lang.org/docs/stable/', 'http://elixir-lang.org/getting-started/']
    self.root_path = 'elixir/api-reference.html'
    self.initial_paths = %w(
      eex/EEx.html
      ex_unit/ExUnit.html
      iex/IEx.html
      logger/Logger.html
      mix/Mix.html
    )
    self.links = {
      home: 'http://elixir-lang.org/',
      code: 'https://github.com/elixir-lang/elixir'
    }

    html_filters.push 'elixir/clean_html', 'elixir/entries', 'title'

    options[:container] = ->(filter) {
      filter.current_url.path.start_with?('/getting-started') ? '#main' : '#content'
    }
    options[:title] = false
    options[:root_title] = 'Elixir'

    options[:attribution] = <<-HTML
      &copy; 2012&ndash;2016 Plataformatec<br>
      Licensed under the Apache License, Version 2.0.
    HTML

    def initial_urls
      super.tap { |urls| urls.last << 'introduction.html' }
    end
  end
end
