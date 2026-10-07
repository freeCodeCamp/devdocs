module Docs
  class TanstackQuery < Tanstack
    self.name = 'TanStack Query'
    self.slug = 'tanstack_query'
    self.type = 'simple'
    self.release = '5.104.1'
    self.base_url = 'https://tanstack.com/query/latest/docs/'
    # The docs root redirects to the overview. Requesting it would store that
    # page twice: once as `index` (the URL we asked for) and again as the overview.
    self.root_path = 'framework/react/overview'
    # The React overview does not link the ESLint plugin, and a second base of
    # the plugin page would contain that one URL and drop the rule pages under
    # `/docs/eslint/<rule>`. `/docs/eslint` itself is a 404, so it cannot be a base.
    self.initial_paths = %w(eslint/eslint-plugin-query)
    self.links = {
      home: 'https://tanstack.com/query',
      code: 'https://github.com/TanStack/query'
    }

    # React only. The other adapters are the same pages with a string replace,
    # and indexing `useQuery` once per framework buries search. `framework/react`
    # without the trailing slash is the empty landing page, so the pattern
    # requires the slash. ESLint lives beside the framework tree, not under it.
    options[:only_patterns] = [%r{\Aframework/react/}, %r{\Aeslint/}]
    # Example galleries are StackBlitz demos. `*.md` URLs are `text/markdown`,
    # which the scraper would ignore, but skipping them avoids a request per page.
    options[:skip_patterns] = [/\.md\z/, /examples/]

    # Container stays `body` so the sidebar is still in the document when
    # InternalUrlsFilter queues links. The clean filter then keeps the h1 and `.prose`.
    html_filters.push 'tanstack/entries', 'tanstack/clean_html'

    def get_latest_version(opts)
      get_npm_version('@tanstack/react-query', opts)
    end
  end
end
