# frozen_string_literal: true

module Docs
  class StoreSubscriber < Subscriber
    self.namespace = 'store'

    def create(event)
      log "Create: #{format_path event.payload[:path]}"
    end

    def update(event)
      log "Update: #{format_path event.payload[:path]}"
    end

    def destroy(event)
      log "Delete: #{format_path event.payload[:path]}"
    end
  end
end
