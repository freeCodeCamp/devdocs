module Docs
  class UrlScraper < Scraper
    class << self
      attr_accessor :params
      attr_accessor :headers
      attr_accessor :force_gzip

      def inherited(subclass)
        super
        subclass.params = params.deep_dup
        subclass.headers = headers.deep_dup
        subclass.force_gzip = force_gzip
      end
    end

    @@rate_limiter = nil

    self.params = {}
    self.headers = { 'User-Agent' => 'DevDocs' }
    self.force_gzip = false

    private

    def request_one(url)
      Request.run url, request_options
    end

    def request_all(urls, &block)
      if options[:rate_limit]
        if @@rate_limiter
          @@rate_limiter.limit = options[:rate_limit]
        else
          @@rate_limiter = RateLimiter.new(options[:rate_limit])
          Typhoeus.before(&@@rate_limiter.to_proc)
        end
      end

      Requester.run urls, request_options: request_options, &block
    end

    def request_options
      options = { params: self.class.params, headers: self.class.headers }
      options[:accept_encoding] = 'gzip' if self.class.force_gzip
      options
    end

    def process_response?(response)
      if response.error?
        raise <<~ERROR
          Error status code (#{response.code}): #{response.return_message}
          #{response.url}
          #{JSON.pretty_generate(response.headers).slice(2..-3)}
        ERROR
      elsif response.blank?
        raise "Empty response body: #{response.url}"
      end

      response.success? && response.html? && process_url?(response.effective_url)
    end

    def process_url?(url)
      base_url.contains?(url)
    end

    def load_capybara_selenium
      require 'capybara/dsl'
      require 'selenium/webdriver'
      Capybara.register_driver :chrome do |app|
        options = Selenium::WebDriver::Chrome::Options.new(args: %w[headless disable-gpu])
        Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
      end
      Capybara.javascript_driver = :chrome
      Capybara.current_driver = :chrome
      Capybara.run_server = false
      Capybara
    end

    module MultipleBaseUrls
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        attr_reader :base_urls

        def base_urls=(urls)
          self.base_url = urls.first
          @base_urls = urls
        end
      end

      def initial_urls
        super + self.class.base_urls[1..-1].deep_dup
      end

      def base_urls
        @base_urls ||= self.class.base_urls.map { |url| URL.parse(url) }
      end

      private

      def process_url?(url)
        base_urls.any? { |base_url| base_url.contains?(url) }
      end

      def process_response(response)
        original_scheme = self.base_url.scheme
        original_host = self.base_url.host
        original_path = self.base_url.path

        effective_base_url = self.base_urls.find { |base_url| base_url.contains?(response.effective_url) }

        self.base_url.scheme = effective_base_url.scheme
        self.base_url.host = effective_base_url.host
        self.base_url.path = effective_base_url.path
        super
      ensure
        self.base_url.scheme = original_scheme
        self.base_url.host = original_host
        self.base_url.path = original_path
      end
    end

    module FixRedirectionsBehavior
      def self.included(base)
        base.extend ClassMethods
      end

      def self.prepended(base)
        class << base
          prepend ClassMethods
        end
      end

      module ClassMethods
        def redirections
          @redirections
        end

        def store_pages(store)
          instrument 'info.doc', msg: 'Fetching redirections...'
          with_redirections do
            instrument 'info.doc', msg: 'Continuing...'
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
        with_filters 'apply_base_url', 'container', 'normalize_urls', 'internal_urls' do
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
        super.merge! redirections: self.class.redirections
      end
    end

    class RateLimiter
      attr_accessor :limit

      def initialize(limit)
        @limit = limit
        @minute = nil
        @counter = 0
      end

      def call(*)
        if @minute != Time.now.min
          @minute = Time.now.min
          @counter = 0
        end

        @counter += 1

        if @counter >= @limit
          wait = Time.now.end_of_minute.to_i - Time.now.to_i + 1
          sleep wait
        end

        true
      end

      def to_proc
        method(:call).to_proc
      end
    end
  end
end
