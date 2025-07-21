# frozen_string_literal: true

module Docs
  class Koa < Github
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

    options[:skip_patterns] = [/\.gif/]
    options[:trailing_slash] = false
    options[:container] = '.markdown-body'



    options[:attribution] = <<-HTML
      &copy; 2020 Koa contributors<br>
      Licensed under the MIT License.
    HTML

    version do
      self.base_url = 'https://github.com/koajs/koa/blob/v3.0.0/docs'
      self.root_path = 'api/index.md'
      self.release = '3.0.0'
      options[:fix_urls] = ->(url) do
        url.sub! 'https://koajs.com/#error-handling', self.base_url + '/error-handling.md'
        url
      end
    end
    
    version '2' do
      self.base_url = 'https://github.com/koajs/koa/blob/v2.16.1/docs'
      self.root_path = 'api/index.md'
      self.release = '2.16.1'
      options[:fix_urls] = ->(url) do
        url.sub! 'https://koajs.com/#error-handling', self.base_url + '/error-handling.md'
        url
      end
    end
    
    version '1' do
      self.base_url = 'https://github.com/koajs/koa/blob/1.7.1/docs'
      self.root_path = 'api/index.md'
      self.release = '1.7.1'
      options[:fix_urls] = ->(url) do
        url.sub! 'https://koajs.com/#error-handling', self.base_url + '/error-handling.md'
        url
      end
    end
    
    def get_latest_version(opts)
      get_npm_version('koa', opts)
    end
  end
end
