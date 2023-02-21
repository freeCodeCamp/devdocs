module Docs
  class Request < Typhoeus::Request
    include Instrumentable

    DEFAULT_OPTIONS = {
      followlocation: true,
      headers: { 'User-Agent' => 'DevDocs' }
    }

    def self.run(*args, &block)
      request = new(*args)
      request.on_complete(&block) if block
      request.run
    end

    def initialize(url, options = {})
      super url.to_s, DEFAULT_OPTIONS.merge(options)
    end

    def response=(value)
      value.extend Response if value
      super
    end

    def run
      instrument 'response.request', url: base_url do |payload|
        response = super
        payload[:response] = response
        response
      end
    end
  end
end
