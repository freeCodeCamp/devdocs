module Docs
  class UrlScraper < Scraper
    class << self
      attr_accessor :params

      def inherited(subclass)
        super
        subclass.params = params.deep_dup
      end
    end

    self.params = {}

    private

    def request_one(url)
      Request.run url, request_options
    end

    def request_all(urls, &block)
      Requester.run urls, request_options: request_options, &block
    end

    def request_options
      { params: self.class.params }
    end

    def process_response?(response)
      response.success? && response.html? && base_url.contains?(response.effective_url)
    end
  end
end
