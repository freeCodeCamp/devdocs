module Docs
  class TanstackRouter < Tanstack
    self.name = 'TanStack Router'
    self.slug = 'tanstack_router'
    self.release = '1.170.41'
    self.base_url = 'https://tanstack.com/router/latest/docs/'
    # Same duplicate-index problem as Query: `/docs/` redirects to `/docs/overview`.
    self.root_path = 'overview'
    self.links = {
      home: 'https://tanstack.com/router',
      code: 'https://github.com/TanStack/router'
    }

    # The overview sidebar only links one routing page. Routing pages link the
    # guides, ESLint, and integrations, so no extra initial paths are required.
    # Solid shows up as examples of the React router, not as its own guide.
    options[:skip_patterns] = [/\.md\z/, /examples/, %r{framework/solid}]

    def get_latest_version(opts)
      get_npm_version('@tanstack/react-router', opts)
    end
  end
end
