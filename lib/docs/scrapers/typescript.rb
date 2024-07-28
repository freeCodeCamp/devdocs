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

    options[:fix_urls_before_parse] = ->(url) do
      url.sub! '/docs/handbook/esm-node.html', '/docs/handbook/modules/reference.html#node16-nodenext'
      url.sub! '/docs/handbook/modules.html', '/docs/handbook/modules/introduction.html'
      url
    end

    options[:skip] = [
      'react-&-webpack.html'
    ]

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
      &copy; 2012-2024 Microsoft<br>
      Licensed under the Apache License, Version 2.0.
    HTML

    version do
      self.release = '5.5.4'
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
