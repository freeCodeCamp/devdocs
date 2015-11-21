module Docs
  class UrlScraper < Scraper
    class << self
      attr_accessor :params
      attr_accessor :headers

      def inherited(subclass)
        super
        subclass.params = params.deep_dup
        subclass.headers = headers.deep_dup
      end
    end

    self.params = {}
    self.headers = { 'User-Agent' => 'devdocs.io' }

    private

    def request_one(url)
      Request.run url, request_options
    end

    def request_all(urls, &block)
      Requester.run urls, request_options: request_options, &block
    end

    def request_options
      { params: self.class.params, headers: self.class.headers }
    end

    def process_response?(response)
      response.success? && response.html? && base_url.contains?(response.effective_url)
    end

    module FixRedirectionsBehavior
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        attr_accessor :fix_redirections
        attr_reader :redirections

        def store_pages(store)
          return super unless fix_redirections
          instrument 'info.doc', msg: 'Fetching redirections...'
          with_redirections do
            instrument 'info.doc', msg: 'Building pages...'
            super
          end
        end

        private

        def with_redirections
          @redirections = new.fetch_redirections
          yield
        ensure
          @redirections = nil
        end
      end

      def fetch_redirections
        result = {}
        with_filters 'container', 'normalize_urls', 'internal_urls' do
          build_pages do |page|
            next if page[:response_effective_path] == page[:response_path]
            result[page[:response_path].downcase] = page[:response_effective_path]
          end
        end
        result
      end

      private

      def process_response(response)
        super.merge! response_effective_path: response.effective_path, response_path: response.path
      end

      def additional_options
        { redirections: self.class.redirections }
      end

      def with_filters(*filters)
        stack = FilterStack.new
        stack.push(*filters)
        pipeline.instance_variable_set :@filters, stack.to_a.freeze
        yield
      ensure
        @pipeline = nil
      end
    end

    include FixRedirectionsBehavior
  end
end
