module Docs
  class FilterSubscriber < Subscriber
    self.namespace = 'html_pipeline'

    def call_filter(event)
      log "Filter: #{event.payload[:filter].gsub('Docs::', '').gsub('Filter', '')} [#{event.duration.round}ms]"
    end
  end
end
