module Docs
  class Typescript < UrlScraper
    include MultipleBaseUrls

    self.name = 'TypeScript'
    self.type = 'typescript'

    self.root_path = 'docs/'

    def initial_urls
      [ 'https://www.typescriptlang.org/docs/handbook/',
        'https://www.typescriptlang.org/tsconfig' ]
    end

    self.links = {
      home: 'https://www.typescriptlang.org',
      code: 'https://github.com/Microsoft/TypeScript'
    }

    html_filters.push 'typescript/entries', 'typescript/clean_html', 'title'

    options[:skip_patterns] = [
      /\Abranding/,
      /\Acommunity/,
      /\Adocs\Z/,
      /\Atools/,
      /release-notes/,
      /dt\/search/,
      /play/
    ]

    options[:attribution] = <<-HTML
      &copy; 2012-2025 Microsoft<br>
      Licensed under the Apache License, Version 2.0.
    HTML

    version do
      self.release = '5.8.2'
      self.base_urls = [
        'https://www.typescriptlang.org/docs/handbook/',
        'https://www.typescriptlang.org/'
      ]
    end

    version '5.1' do
      self.release = '5.1.3'
    end

    def get_latest_version(opts)
      get_latest_github_release('Microsoft', 'TypeScript', opts)
    end

  end
end
