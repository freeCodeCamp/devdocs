module Docs
  class Erlang < FileScraper
    self.type = 'erlang'
    self.root_path = 'doc/index.html'
    self.links = {
      home: 'https://www.erlang.org/',
      code: 'https://github.com/erlang/otp'
    }

    html_filters.insert_after 'container', 'erlang/pre_clean_html'
    html_filters.push 'erlang/entries', 'erlang/clean_html'

    options[:only_patterns] = [
      /\Alib/,
      /\Adoc\/\w+\//,
      /\Aerts.+\/html/
    ]

    options[:skip_patterns] = [
      /pdf/,
      /release_notes/,
      /result/,
      /java/,
      /\.erl\z/,
      /\/html\/.*_app\.html\z/,
      /_examples\.html\z/,
      /\Alib\/edoc/,
      /\Alib\/erl_docgen/,
      /\Alib\/hipe/,
      /\Alib\/ose/,
      /\Alib\/test_server/,
      /\Alib\/jinterface/,
      /\Alib\/wx/,
      /\Alib\/ic/,
      /\Alib\/Cos/i
    ]

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2023 Ericsson AB<br>
      Licensed under the Apache License, Version 2.0.
    HTML

    version '26' do
      self.release = '26.0.1'
    end

    version '25' do
      self.release = '25.3.2.2'
    end

    version '24' do
      self.release = '24.0'
    end

    version '23' do
      self.release = '23.2'
    end

    version '22' do
      self.release = '22.3'
    end

    version '21' do
      self.release = '21.0'
    end

    version '20' do
      self.release = '20.3'
    end

    version '19' do
      self.release = '19.3'
    end

    version '18' do
      self.release = '18.3'
    end

    def get_latest_version(opts)
      get_latest_github_release('erlang', 'otp', opts)[4..-1]
    end
  end
end
