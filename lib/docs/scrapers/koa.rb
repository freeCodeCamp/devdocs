# frozen_string_literal: true

module Docs
  class Koa < Github
    self.base_url = 'https://github.com/koajs/koa/tree/master/docs'
    self.release = '2.15.0'

    self.root_path = 'api/index.md'
    self.initial_paths = %w[
      error-handling
      faq
      guide
      koa-vs-express
      migration
      troubleshooting
      api/index
      api/context
      api/request
      api/response
    ].map { |name| name + '.md' }

    self.links = {
      home: 'https://koajs.com/',
      code: 'https://github.com/koajs/koa'
    }

    html_filters.push 'koa/clean_html', 'koa/entries'

    options[:skip] = %w[middleware.gif]
    options[:trailing_slash] = false
    options[:container] = '.markdown-body'

    options[:fix_urls] = ->(url) do
      url.sub! 'https://koajs.com/#error-handling', Koa.base_url + '/error-handling.md'
      url
    end

    options[:attribution] = <<-HTML
      &copy; 2020 Koa contributors<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_npm_version('koa', opts)
    end
  end
end
