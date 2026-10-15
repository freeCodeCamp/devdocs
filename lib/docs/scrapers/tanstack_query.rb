module Docs
  class TanstackQuery < Tanstack
    self.name = 'TanStack Query'
    self.slug = 'tanstack_query'
    self.release = '5.104.1'
    self.base_url = 'https://tanstack.com/query/latest/docs/'
    self.root_path = 'framework/react/overview'
    self.initial_paths = %w(eslint/eslint-plugin-query)
    self.links = {
      home: 'https://tanstack.com/query',
      code: 'https://github.com/TanStack/query'
    }

    # React only, the other adapters duplicate the same pages
    options[:only_patterns] = [/\Aframework\/react\//, /\Aeslint\//]
    options[:skip_patterns] = [/\.md\z/, /examples/]

    def get_latest_version(opts)
      get_npm_version('@tanstack/react-query', opts)
    end
  end
end
