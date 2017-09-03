# frozen_string_literal: true

module Docs
  class ScraperSubscriber < Subscriber
    self.namespace = 'scraper'

    def queued(event)
      event.payload[:urls].each do |url|
        log "Queue:   #{format_url url}"
      end
    end

    alias_method :running, :queued

    def ignore_response(event)
      msg = "Ignore:  #{format_url event.payload[:response].url}"
      msg += " [#{event.payload[:response].code}]" if event.payload[:response].respond_to?(:code)
      log(msg)
    end

    def process_response(event)
      log "Process: #{format_url event.payload[:response].url} [#{event.duration.round}ms]"
    end
  end
end
