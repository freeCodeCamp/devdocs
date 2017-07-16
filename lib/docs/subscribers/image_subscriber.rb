# frozen_string_literal: true

module Docs
  class ImageSubscriber < Subscriber
    self.namespace = 'image'

    def broken(event)
      log "Skipped broken image (#{event.payload[:code]}): #{event.payload[:url]}"
    end

    def invalid(event)
      log "Skipped invalid image (#{event.payload[:content_type]}): #{event.payload[:url]}"
    end

    def too_big(event)
      log "Skipped large image (#{(event.payload[:size] / 1_000.0).round} KB): #{event.payload[:url]}"
    end

    def error(event)
      exception = event.payload[:exception]
      log "ERROR: #{event.payload[:url]}"
      puts "  #{exception.class}: #{exception.message.gsub("\n", "\n    ")}"
      puts exception.backtrace.select { |line| line.start_with?(Docs.root_path) }.join("\n  ").prepend("\n  ")
      puts "\n"
    end
  end
end
