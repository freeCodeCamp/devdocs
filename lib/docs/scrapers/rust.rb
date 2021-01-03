# frozen_string_literal: true

module Docs
  class Rust < UrlScraper
    self.type = 'rust'
    self.release = '1.49.0'
    self.base_url = 'https://doc.rust-lang.org/'
    self.root_path = 'book/index.html'
    self.initial_paths = %w(
      reference/introduction.html
      std/index.html
      error-index.html)
    self.links = {
      home: 'https://www.rust-lang.org/',
      code: 'https://github.com/rust-lang/rust'
    }

    html_filters.push 'rust/entries', 'rust/clean_html'

    options[:only_patterns] = [
      /\Abook\//,
      /\Areference\//,
      /\Acollections\//,
      /\Astd\// ]

    options[:skip] = %w(book/README.html book/ffi.html)
    options[:skip_patterns] = [/(?<!\.html)\z/, /\/print\.html/, /\Abook\/second-edition\//]

    options[:fix_urls] = ->(url) do
      url.sub! %r{(#{Rust.base_url}.+/)\z}, '\1index.html'
      url.sub! '/unicode/u_str', '/unicode/str/'
      url.sub! '/std/std/', '/std/'
      url
    end

    options[:attribution] = <<-HTML
      &copy; 2010 The Rust Project Developers<br>
      Licensed under the Apache License, Version 2.0 or the MIT license, at your option.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://www.rust-lang.org/', opts)
      label = doc.at_css('.button-download + p > a').content
      label.sub(/Version /, '')
    end

    private

    REDIRECT_RGX = /http-equiv="refresh"/i
    NOT_FOUND_RGX = /<title>Not Found<\/title>/

    def process_response?(response)
      !(response.body =~ REDIRECT_RGX || response.body =~ NOT_FOUND_RGX || response.body.blank?)
    end
  end
end
