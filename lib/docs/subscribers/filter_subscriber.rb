# frozen_string_literal: true

module Docs
  class FilterSubscriber < Subscriber
    self.namespace = 'html_pipeline'

    def call_filter(event)
      log "Filter: #{event.payload[:filter].remove('Docs::').remove('Filter')} [#{event.duration.round}ms]"
    end
  end
end
