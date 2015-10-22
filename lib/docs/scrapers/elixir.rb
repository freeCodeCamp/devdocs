module Docs
  class Elixir < UrlScraper
    self.name = 'Elixir'
    self.type = 'elixir'
    self.version = '1.1.1'
    self.base_url = 'http://elixir-lang.org/docs/stable/elixir/'
    self.root_path = 'extra-api-reference.html'
    self.links = {
      home: 'https://elixir-lang.org/',
      code: 'https://github.com/elixir-lang/elixir'
    }

    html_filters.push 'elixir/clean_html', 'elixir/entries', 'title'

    # Skip exceptions
    options[:skip_patterns] = [/Error/]
    # Skip protocols
    options[:skip] = %w(
      Collectable.html
      Enumerable.html
      Inspect.html
      List.Chars.html
      String.Chars.html
    )

    options[:follow_links] = ->(filter) { filter.root_page? }
    options[:container] = "#content"
    options[:title] = false
    options[:root_title] = 'Elixir'

    options[:attribution] = <<-HTML
      &copy; 2012 Plataformatec<br>
      Licensed under the Apache License, Version 2.0
    HTML
  end
end
