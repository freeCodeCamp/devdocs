module Docs
  class Erlang < FileScraper
    self.version = '18.1'
    self.type = 'erlang'
    self.dir = File.expand_path('~/devdocs/erlang')
    self.base_url = 'http://www.erlang.org/doc/'
    self.root_path = 'doc/index.html'
    self.links = {
      home: 'http://erlang.org/'
    }

    html_filters.push 'erlang/entries', 'erlang/clean_html'

    # The folder structure of the offline documentation
    # differs from the online structure. We need
    # to replace the attribution filter to generate the
    # right attribution_link
    text_filters.replace 'attribution', 'erlang/attribution'

    # Do not scrape these unnecessary links
    options[:skip_patterns] = [
      /\.pdf$/,
      /users_guide\.html$/,
      /release_notes\.html$/,
      /\/html\/.*_app\.html$/,
      /\/html\/unicode_usage\.html$/,
      /\/html\/io_protocol\.html$/
    ]

    options[:title] = false

    # Scrape stdlib documentation only
    options[:only_patterns] = [/stdlib/]

    options[:attribution] = <<-HTML
      Copyright &copy; 1999-2015 Ericsson AB<br>
      Licensed under the Apache License, Version 2.0.
    HTML
  end
end
