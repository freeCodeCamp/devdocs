module Docs
  class ReactBootstrap < UrlScraper
    self.name = 'React Bootstrap'
    self.slug = 'react_bootstrap'
    self.type = 'simple'
    self.release = '1.5.0'
    self.base_url = 'https://react-bootstrap.github.io/'

    self.links = {
      home: 'https://react-bootstrap.github.io',
      code: 'https://github.com/react-bootstrap/react-bootstrap'
    }

    html_filters.push 'react_bootstrap/entries', 'react_bootstrap/clean_html'

    options[:skip] = %w(
      react-overlays/
    )

    options[:replace_paths] = {
    }

    options[:trailing_slash] = true

    options[:attribution] = <<-HTML
      &copy; 2014&ndash;present Stephen J. Collings, Matthew Honnibal, Pieter Vanderwerff<br>
      Licensed under the MIT License (MIT).
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://react-bootstrap.github.io/', opts)
      doc.at_css('.my-2').content.split()[-1].strip[0..-1]
    end
  end
end
