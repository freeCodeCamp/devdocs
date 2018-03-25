require 'set'

module Docs
  class Scraper < Doc
    class << self
      attr_accessor :base_url, :root_path, :initial_paths, :options, :html_filters, :text_filters, :stubs

      def inherited(subclass)
        super

        subclass.class_eval do
          extend AutoloadHelper
          autoload_all "docs/filters/#{to_s.demodulize.underscore}", 'filter'
        end

        subclass.base_url = base_url
        subclass.root_path = root_path
        subclass.initial_paths = initial_paths.dup
        subclass.options = options.deep_dup
        subclass.html_filters = html_filters.inheritable_copy
        subclass.text_filters = text_filters.inheritable_copy
        subclass.stubs = stubs.dup
      end

      def filters
        html_filters.to_a + text_filters.to_a
      end

      def stub(path, &block)
        @stubs[path] = block
        @stubs
      end
    end

    include Instrumentable

    self.initial_paths = []
    self.options = {}
    self.stubs = {}

    self.html_filters = FilterStack.new
    self.text_filters = FilterStack.new

    html_filters.push 'apply_base_url', 'container', 'clean_html', 'normalize_urls', 'internal_urls', 'normalize_paths', 'parse_cf_email'
    text_filters.push 'images' # ensure the images filter runs after all html filters
    text_filters.push 'inner_html', 'clean_text', 'attribution'

    def initialize
      super
      initialize_stubs
    end

    def initialize_stubs
      self.class.stubs.each do |path, block|
        Typhoeus.stub(url_for(path)).and_return do
          Typhoeus::Response.new \
            effective_url: url_for(path),
            code: 200,
            headers: { 'Content-Type' => 'text/html' },
            body: self.instance_exec(&block)
        end
      end
    end

    def build_page(path)
      response = request_one url_for(path)
      result = handle_response(response)
      yield result if block_given?
      result
    end

    def build_pages
      history = Set.new initial_urls.map(&:downcase)
      instrument 'running.scraper', urls: initial_urls

      request_all initial_urls do |response|
        next unless data = handle_response(response)
        yield data
        next unless data[:internal_urls].present?
        next_urls = data[:internal_urls].select { |url| history.add?(url.downcase) }
        instrument 'queued.scraper', urls: next_urls
        next_urls
      end
    end

    def base_url
      @base_url ||= URL.parse self.class.base_url
    end

    def root_url
      @root_url ||= root_path? ? URL.parse(File.join(base_url.to_s, root_path)) : base_url.normalize
    end

    def root_path
      self.class.root_path
    end

    def root_path?
      root_path.present? && root_path != '/'
    end

    def initial_paths
      self.class.initial_paths
    end

    def initial_urls
      @initial_urls ||= [root_url.to_s].concat(initial_paths.map(&method(:url_for))).freeze
    end

    def pipeline
      @pipeline ||= ::HTML::Pipeline.new(self.class.filters).tap do |pipeline|
        pipeline.instrumentation_service = Docs
      end
    end

    def options
      @options ||= self.class.options.deep_dup.tap do |options|
        options.merge! base_url: base_url, root_url: root_url,
                       root_path: root_path, initial_paths: initial_paths,
                       version: self.class.version, release: self.class.release

        if root_path?
          (options[:skip] ||= []).concat ['', '/']
        end

        if options[:only] || options[:only_patterns]
          (options[:only] ||= []).concat initial_paths + (root_path? ? [root_path] : ['', '/'])
        end

        options.merge!(additional_options)
        options.freeze
      end
    end

    private

    def request_one(url)
      raise NotImplementedError
    end

    def request_all(url, &block)
      raise NotImplementedError
    end

    def process_response?(response)
      raise NotImplementedError
    end

    def url_for(path)
      if path.empty? || path == '/'
        root_url.to_s
      else
        File.join(base_url.to_s, path)
      end
    end

    def handle_response(response)
      if process_response?(response)
        instrument 'process_response.scraper', response: response do
          process_response(response)
        end
      else
        instrument 'ignore_response.scraper', response: response
      end
    rescue => e
      if Docs.rescue_errors
        instrument 'error.doc', exception: e, url: response.url
        nil
      else
        raise e
      end
    end

    def process_response(response)
      data = {}
      html, title = parse(response)
      context = pipeline_context(response)
      context[:html_title] = title
      pipeline.call(html, context, data)
      data
    end

    def pipeline_context(response)
      options.merge url: response.url
    end

    def parse(response)
      parser = Parser.new(response.body)
      [parser.html, parser.title]
    end

    def with_filters(*filters)
      stack = FilterStack.new
      stack.push(*filters)
      pipeline.instance_variable_set :@filters, stack.to_a.freeze
      yield
    ensure
      @pipeline = nil
    end

    def additional_options
      {}
    end

    module FixInternalUrlsBehavior
      def self.included(base)
        base.extend ClassMethods
      end

      def self.prepended(base)
        class << base
          prepend ClassMethods
        end
      end

      module ClassMethods
        def internal_urls
          @internal_urls
        end

        def store_pages(store)
          instrument 'info.doc', msg: 'Building internal urls...'
          with_internal_urls do
            instrument 'info.doc', msg: 'Continuing...'
            super
          end
        end

        private

        def with_internal_urls
          @internal_urls = new.fetch_internal_urls
          yield
        ensure
          @internal_urls = nil
        end
      end

      def fetch_internal_urls
        result = []
        build_pages do |page|
          result << page[:subpath] if page[:entries].present?
        end
        result
      end

      def initial_urls
        return super unless self.class.internal_urls
        @initial_urls ||= self.class.internal_urls.map(&method(:url_for)).freeze
      end

      private

      def additional_options
        if self.class.internal_urls
          super.merge! \
            only: self.class.internal_urls.to_set,
            only_patterns: nil,
            skip: nil,
            skip_patterns: nil,
            skip_links: nil,
            fixed_internal_urls: true
        else
          super
        end
      end

      def process_response(response)
        super.merge! response_url: response.url
      end
    end
  end
end
