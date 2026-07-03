module Docs
  class Elixir < UrlScraper
    include MultipleBaseUrls

    self.name = 'Elixir'
    self.type = 'elixir'
    self.root_path = 'introduction.html'
    self.links = {
      home: 'https://elixir-lang.org/',
      code: 'https://github.com/elixir-lang/elixir'
    }

    html_filters.push 'elixir/clean_html', 'elixir/entries', 'title'

    options[:container] = '#content'
    options[:title] = false
    options[:root_title] = 'Elixir'

    options[:attribution] = <<-HTML
      &copy; 2012-2026 The Elixir Team<br>
      Licensed under the Apache License, Version 2.0.
    HTML

    def initial_urls
      [ "https://elixir.hexdocs.pm/#{self.class.release}/introduction.html",
        "https://eex.hexdocs.pm/#{self.class.release}/EEx.html",
        "https://ex-unit.hexdocs.pm/#{self.class.release}/ExUnit.html",
        "https://iex.hexdocs.pm/#{self.class.release}/IEx.html",
        "https://logger.hexdocs.pm/#{self.class.release}/Logger.html",
        "https://mix.hexdocs.pm/#{self.class.release}/Mix.html" ]
    end

    version '1.20' do
      self.release = '1.20.1'
      self.base_urls = [
        "https://elixir.hexdocs.pm/#{release}/",
        "https://eex.hexdocs.pm/#{release}/",
        "https://ex-unit.hexdocs.pm/#{release}/",
        "https://iex.hexdocs.pm/#{release}/",
        "https://logger.hexdocs.pm/#{release}/",
        "https://mix.hexdocs.pm/#{release}/"
      ]
    end

    version '1.18' do
      self.release = '1.18.1'
      self.base_urls = [
        "https://elixir.hexdocs.pm/#{release}/",
        "https://eex.hexdocs.pm/#{release}/",
        "https://ex-unit.hexdocs.pm/#{release}/",
        "https://iex.hexdocs.pm/#{release}/",
        "https://logger.hexdocs.pm/#{release}/",
        "https://mix.hexdocs.pm/#{release}/"
      ]
    end

    version '1.17' do
      self.release = '1.17.2'
      self.base_urls = [
        "https://elixir.hexdocs.pm/#{release}/",
        "https://eex.hexdocs.pm/#{release}/",
        "https://ex-unit.hexdocs.pm/#{release}/",
        "https://iex.hexdocs.pm/#{release}/",
        "https://logger.hexdocs.pm/#{release}/",
        "https://mix.hexdocs.pm/#{release}/"
      ]
    end

    version '1.16' do
      self.release = '1.16.3'
      self.base_urls = [
        "https://elixir.hexdocs.pm/#{release}/",
        "https://eex.hexdocs.pm/#{release}/",
        "https://ex-unit.hexdocs.pm/#{release}/",
        "https://iex.hexdocs.pm/#{release}/",
        "https://logger.hexdocs.pm/#{release}/",
        "https://mix.hexdocs.pm/#{release}/"
      ]
    end

    # scraping of older versions is no longer supported!

    version '1.15' do
      self.release = '1.15.4'
      self.base_urls = [
        "https://elixir.hexdocs.pm/#{release}/",
        "https://eex.hexdocs.pm/#{release}/",
        "https://ex-unit.hexdocs.pm/#{release}/",
        "https://iex.hexdocs.pm/#{release}/",
        "https://logger.hexdocs.pm/#{release}/",
        "https://mix.hexdocs.pm/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end

    version '1.14' do
      self.release = '1.14.1'
      self.base_urls = [
        "https://elixir.hexdocs.pm/#{release}/",
        "https://eex.hexdocs.pm/#{release}/",
        "https://ex-unit.hexdocs.pm/#{release}/",
        "https://iex.hexdocs.pm/#{release}/",
        "https://logger.hexdocs.pm/#{release}/",
        "https://mix.hexdocs.pm/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end

    version '1.13' do
      self.release = '1.13.4'
      self.base_urls = [
        "https://elixir.hexdocs.pm/#{release}/",
        "https://eex.hexdocs.pm/#{release}/",
        "https://ex-unit.hexdocs.pm/#{release}/",
        "https://iex.hexdocs.pm/#{release}/",
        "https://logger.hexdocs.pm/#{release}/",
        "https://mix.hexdocs.pm/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end

    version '1.12' do
      self.release = '1.12.0'
      self.base_urls = [
        "https://elixir.hexdocs.pm/#{release}/",
        "https://eex.hexdocs.pm/#{release}/",
        "https://ex-unit.hexdocs.pm/#{release}/",
        "https://iex.hexdocs.pm/#{release}/",
        "https://logger.hexdocs.pm/#{release}/",
        "https://mix.hexdocs.pm/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end

    version '1.11' do
      self.release = '1.11.2'
      self.base_urls = [
        "https://elixir.hexdocs.pm/#{release}/",
        "https://eex.hexdocs.pm/#{release}/",
        "https://ex-unit.hexdocs.pm/#{release}/",
        "https://iex.hexdocs.pm/#{release}/",
        "https://logger.hexdocs.pm/#{release}/",
        "https://mix.hexdocs.pm/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end

    version '1.10' do
      self.release = '1.10.4'
      self.base_urls = [
        "https://elixir.hexdocs.pm/#{release}/",
        "https://eex.hexdocs.pm/#{release}/",
        "https://ex-unit.hexdocs.pm/#{release}/",
        "https://iex.hexdocs.pm/#{release}/",
        "https://logger.hexdocs.pm/#{release}/",
        "https://mix.hexdocs.pm/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end

    version '1.9' do
      self.release = '1.9.4'
      self.base_urls = [
        "https://elixir.hexdocs.pm/#{release}/",
        "https://eex.hexdocs.pm/#{release}/",
        "https://ex-unit.hexdocs.pm/#{release}/",
        "https://iex.hexdocs.pm/#{release}/",
        "https://logger.hexdocs.pm/#{release}/",
        "https://mix.hexdocs.pm/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end

    version '1.8' do
      self.release = '1.8.2'
      self.base_urls = [
        "https://elixir.hexdocs.pm/#{release}/",
        "https://eex.hexdocs.pm/#{release}/",
        "https://ex-unit.hexdocs.pm/#{release}/",
        "https://iex.hexdocs.pm/#{release}/",
        "https://logger.hexdocs.pm/#{release}/",
        "https://mix.hexdocs.pm/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end

    version '1.7' do
      self.release = '1.7.4'
      self.base_urls = [
        "https://elixir.hexdocs.pm/#{release}/",
        "https://eex.hexdocs.pm/#{release}/",
        "https://ex-unit.hexdocs.pm/#{release}/",
        "https://iex.hexdocs.pm/#{release}/",
        "https://logger.hexdocs.pm/#{release}/",
        "https://mix.hexdocs.pm/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end

    version '1.6' do
      self.release = '1.6.6'
      self.base_urls = [
        "https://elixir.hexdocs.pm/#{release}/",
        "https://eex.hexdocs.pm/#{release}/",
        "https://ex-unit.hexdocs.pm/#{release}/",
        "https://iex.hexdocs.pm/#{release}/",
        "https://logger.hexdocs.pm/#{release}/",
        "https://mix.hexdocs.pm/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end

    version '1.5' do
      self.release = '1.5.3'
      self.base_urls = [
        "https://elixir.hexdocs.pm/#{release}/",
        "https://eex.hexdocs.pm/#{release}/",
        "https://ex-unit.hexdocs.pm/#{release}/",
        "https://iex.hexdocs.pm/#{release}/",
        "https://logger.hexdocs.pm/#{release}/",
        "https://mix.hexdocs.pm/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end

    version '1.4' do
      self.release = '1.4.5'
      self.base_urls = [
        "https://elixir.hexdocs.pm/#{release}/",
        "https://eex.hexdocs.pm/#{release}/",
        "https://ex-unit.hexdocs.pm/#{release}/",
        "https://iex.hexdocs.pm/#{release}/",
        "https://logger.hexdocs.pm/#{release}/",
        "https://mix.hexdocs.pm/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end

    version '1.3' do
      self.release = '1.3.4'
      self.base_urls = [
        "https://elixir.hexdocs.pm/#{release}/",
        "https://eex.hexdocs.pm/#{release}/",
        "https://ex-unit.hexdocs.pm/#{release}/",
        "https://iex.hexdocs.pm/#{release}/",
        "https://logger.hexdocs.pm/#{release}/",
        "https://mix.hexdocs.pm/#{release}/",
        'https://elixir-lang.org/getting-started/'
      ]
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://elixir.hexdocs.pm/api-reference.html', opts)
      doc.at_css('.sidebar-projectVersion').content.strip[1..-1]
    end
  end
end
