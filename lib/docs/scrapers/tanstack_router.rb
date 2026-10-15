module Docs
  class TanstackRouter < Tanstack
    self.name = 'TanStack Router'
    self.slug = 'tanstack_router'
    self.release = '1.170.41'
    self.base_url = 'https://tanstack.com/router/latest/docs/'
    self.root_path = 'overview'
    self.links = {
      home: 'https://tanstack.com/router',
      code: 'https://github.com/TanStack/router'
    }

    options[:skip_patterns] = [/\.md\z/, /examples/, /framework\/solid/]

    def get_latest_version(opts)
      get_npm_version('@tanstack/react-router', opts)
    end
  end
end
