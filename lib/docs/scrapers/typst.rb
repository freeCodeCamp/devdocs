module Docs
  class Typst < UrlScraper
    self.type = 'simple'
    self.release = '0.15.1'
    self.base_url = 'https://typst.app/docs/reference/'
    self.links = {
      home: 'https://typst.app/',
      code: 'https://github.com/typst/typst'
    }

    html_filters.push 'typst/entries', 'typst/clean_html'

    options[:container] = '.main-grid'
    # Some rendered examples exceed the core filter's 120 KB image limit.
    # The largest image in the bundle is 355 KB.
    options[:max_image_size] = 400_000

    options[:attribution] = <<-HTML
      &copy; Typst GmbH and contributors<br>
      Licensed under the Apache License, Version 2.0.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('typst', 'typst', opts)
    end
  end
end
