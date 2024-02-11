module Docs
    class Nextjs < UrlScraper
        self.name = 'nextjs'
        self.type = 'simple'
        self.release = 'v14.1.0'
        self.base_url = 'https://nextjs.org/docs'
        self.initial_paths = %w(reference/)
        self.links = {
          home: 'https://www.nextjs.org/',
          code: 'https://github.com/vercel/next.js'
        }

        html_filters.push 'nextjs/entries', 'nextjs/clean_html'

        options[:attribution] = <<-HTML
          &copy; 2024 Vercel, Inc.
          Licensed under the MIT License.
        HTML
    end
end
