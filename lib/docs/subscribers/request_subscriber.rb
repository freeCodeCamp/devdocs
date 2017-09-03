# frozen_string_literal: true

module Docs
  class RequestSubscriber < Subscriber
    self.namespace = 'request'

    def response(event)
      log "Request: #{format_url event.payload[:url]} [#{event.payload[:response].code}] [#{event.duration.round}ms]"
    end
  end
end
