module Docs
  class Elixir < UrlScraper
    self.name = 'Elixir'
    self.type = 'elixir'
    self.version = '1.2.0'
    self.base_url = 'http://elixir-lang.org/docs/stable/'
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

    options[:container] = "#content"
    options[:title] = false
    options[:root_title] = 'Elixir'

    options[:attribution] = <<-HTML
      &copy; 2012 Plataformatec<br>
      Licensed under the Apache License, Version 2.0.
    HTML
  end
end
