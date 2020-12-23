module Docs
  class Typescript < UrlScraper
    include MultipleBaseUrls

    self.name = 'TypeScript'
    self.type = 'simple'
    self.release = '4.1.3'
    self.base_urls = [
      'https://www.typescriptlang.org/docs/handbook/',
      'https://www.typescriptlang.org/'
    ]

    def initial_urls
      [ 'https://www.typescriptlang.org/docs/handbook/',
        'https://www.typescriptlang.org/tsconfig' ]
    end

    self.links = {
      home: 'https://www.typescriptlang.org',
      code: 'https://github.com/Microsoft/TypeScript'
    }

    html_filters.push 'typescript/entries', 'typescript/clean_html', 'title'

    options[:container] = 'main'

    options[:skip] = [
      'react-&-webpack.html'
    ]

    options[:skip_patterns] = [
      /2/,
      /release-notes/,
      /play\//
    ]

    options[:attribution] = <<-HTML
      &copy; 2012-2020 Microsoft<br>
      Licensed under the Apache License, Version 2.0.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('Microsoft', 'TypeScript', opts)
    end

  end
end
