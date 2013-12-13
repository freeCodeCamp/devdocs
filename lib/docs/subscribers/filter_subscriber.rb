module Docs
  class FilterSubscriber < Subscriber
    self.namespace = 'html_pipeline'

    def call_filter(event)
      log "Filter: #{event.payload[:filter].sub('Docs::', '').sub('Filter', '')} [#{event.duration.round}ms]"
    end
  end
end
