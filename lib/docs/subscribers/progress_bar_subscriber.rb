# frozen_string_literal: true

require 'progress_bar'

module Docs
  class ProgressBarSubscriber < Subscriber
    self.namespace = 'scraper'

    def running(event)
      @progress_bar = ::ProgressBar.new event.payload[:urls].length
      @progress_bar.write
    end

    def queued(event)
      @progress_bar.max += event.payload[:urls].length
      @progress_bar.write
    end

    def process_response(event)
      @progress_bar.increment!
    end

    def ignore_response(event)
      @progress_bar.increment!
    end
  end
end
