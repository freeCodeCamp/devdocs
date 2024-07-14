module Docs
    class Nextjs < UrlScraper
        self.name = 'Next.js'
        self.slug = 'nextjs'
        self.type = 'simple'
        self.release = '14.2.4'
        self.base_url = 'https://nextjs.org/docs'
        self.initial_paths = %w(reference/)
        self.links = {
          home: 'https://www.nextjs.org/',
          code: 'https://github.com/vercel/next.js'
        }

        html_filters.push 'nextjs/entries', 'nextjs/clean_html'
        options[:download_images] = false

        options[:attribution] = <<-HTML
          &copy; 2024 Vercel, Inc.<br>
          Licensed under the MIT License.
        HTML

      def get_latest_version(opts)
          get_npm_version('next', opts)
      end
    end
end
