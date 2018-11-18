# frozen_string_literal: true

module Docs
  class RequesterSubscriber < Subscriber
    self.namespace = 'requester'

    def handle_response(event)
      if event.duration > 10_000
        log "WARN: #{format_url event.payload[:url]} was slow to process (#{(event.duration / 1000).round}s)"
      end
    end
  end
end
