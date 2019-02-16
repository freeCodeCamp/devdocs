module Docs
  class Elixir < UrlScraper
    include MultipleBaseUrls

    self.name = 'Elixir'
    self.type = 'elixir'
    self.root_path = 'api-reference.html'
    self.links = {
      home: 'https://elixir-lang.org/',
      code: 'https://github.com/elixir-lang/elixir'
    }

    html_filters.push 'elixir/clean_html', 'elixir/entries', 'title'

    options[:container] = ->(filter) {
      filter.current_url.path.start_with?('/getting-started') ? '#main' : '#content'
    }
    options[:title] = false
    options[:root_title] = 'Elixir'

    options[:attribution] = <<-HTML
      &copy; 2012 Plataformatec<br>
      Licensed under the Apache License, Version 2.0.
    HTML

    def initial_urls
      [ "https://hexdocs.pm/elixir/#{self.class.release}/api-reference.html",
        "https://hexdocs.pm/eex/#{self.class.release}/EEx.html",
        "https://hexdocs.pm/ex_unit/#{self.class.release}/ExUnit.html",
        "https://hexdocs.pm/iex/#{self.class.release}/IEx.html",
        "https://hexdocs.pm/logger/#{self.class.release}/Logger.html",
        "https://hexdocs.pm/mix/#{self.class.release}/Mix.html",
        "https://elixir-lang.org/getting-started/introduction.html" ]
    end

    version '1.7' do
      self.release = '1.7.3'
      self.base_urls = [
        "https://hexdocs.pm/elixir/#{release}/",
        "https://hexdocs.pm/eex/#{release}/",
        "https://hexdocs.pm/ex_unit/#{release}/",
        "https://hexdocs.pm/iex/#{release}/",
        "https://hexdocs.pm/logger/#{release}/",
        "https://hexdocs.pm/mix/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end

    version '1.6' do
      self.release = '1.6.5'
      self.base_urls = [
        "https://hexdocs.pm/elixir/#{release}/",
        "https://hexdocs.pm/eex/#{release}/",
        "https://hexdocs.pm/ex_unit/#{release}/",
        "https://hexdocs.pm/iex/#{release}/",
        "https://hexdocs.pm/logger/#{release}/",
        "https://hexdocs.pm/mix/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end

    version '1.5' do
      self.release = '1.5.3'
      self.base_urls = [
        "https://hexdocs.pm/elixir/#{release}/",
        "https://hexdocs.pm/eex/#{release}/",
        "https://hexdocs.pm/ex_unit/#{release}/",
        "https://hexdocs.pm/iex/#{release}/",
        "https://hexdocs.pm/logger/#{release}/",
        "https://hexdocs.pm/mix/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end

    version '1.4' do
      self.release = '1.4.5'
      self.base_urls = [
        "https://hexdocs.pm/elixir/#{release}/",
        "https://hexdocs.pm/eex/#{release}/",
        "https://hexdocs.pm/ex_unit/#{release}/",
        "https://hexdocs.pm/iex/#{release}/",
        "https://hexdocs.pm/logger/#{release}/",
        "https://hexdocs.pm/mix/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end

    version '1.3' do
      self.release = '1.3.4'
      self.base_urls = [
        "https://hexdocs.pm/elixir/#{release}/",
        "https://hexdocs.pm/eex/#{release}/",
        "https://hexdocs.pm/ex_unit/#{release}/",
        "https://hexdocs.pm/iex/#{release}/",
        "https://hexdocs.pm/logger/#{release}/",
        "https://hexdocs.pm/mix/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end
  end
end
