module Docs
  class ReactBootstrap < UrlScraper
    self.name = 'React Bootstrap'
    self.slug = 'react_bootstrap'
    self.type = 'simple'
    self.release = '2.8.0'
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
      &copy; 2023 React Bootstrap.<br>
      Licensed under the MIT License (MIT).
    HTML
  end
end
