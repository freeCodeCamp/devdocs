module Docs
    class Nextjs < UrlScraper
        self.name = 'nextjs`'
        self.type = 'simple'
        self.release = 'v14.1.0'
        self.base_url = 'https://nextjs.org/docs'
            self.initial_paths = %w(reference/)
            html_filters.push 'nextjs/entries', 'nextjs/clean_html'
    end
end