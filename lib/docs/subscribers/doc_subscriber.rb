# frozen_string_literal: true

module Docs
  class DocSubscriber < Subscriber
    self.namespace = 'doc'

    def index(event)
      before, after = parse_payload(event)
      size = event.payload[:after].bytesize
      size_diff = size - event.payload[:before].bytesize
      log "Entries: (#{(size / 1_000.0).ceil} KB, #{'+' if size_diff >= 0}#{(size_diff / 1_000.0).ceil} KB)"
      log_diff before['entries'], after['entries'], 'name'
      log "Types:"
      log_diff before['types'],   after['types'],   'name'
    end

    def db(event)
      before, after = parse_payload(event)
      size = event.payload[:after].bytesize
      size_diff = size - event.payload[:before].bytesize
      log "Files: (#{(size / 1_000_000.0).ceil(1)} MB, #{'+' if size_diff >= 0}#{(size_diff / 1_000_000.0).ceil(1)} MB)"
      log_diff before.keys, after.keys
    end

    def info(event)
      log event.payload[:msg]
    end

    def warn(event)
      log "ERROR: #{event.payload[:msg]}"
    end

    def error(event)
      exception = event.payload[:exception]
      log "ERROR:"
      puts "  #{event.payload[:url]}"
      puts "  #{exception.class}: #{exception.message.gsub("\n", "\n    ")}"
      puts exception.backtrace.select { |line| line.start_with?(Docs.root_path) }.join("\n  ").prepend("\n  ")
      puts "\n"
    end

    private

    def parse_payload(event)
      [JSON.parse(event.payload[:before]), JSON.parse(event.payload[:after])]
    end

    def log_diff(before, after, prop = nil)
      before ||= []
      after  ||= []

      if prop
        before = before.map { |obj| obj[prop] }
        after  = after.map  { |obj| obj[prop] }
      end

      created, updated, deleted = (after - before), (before & after), (before - after)

      log "  Updated: #{updated.length}"
      log "  Created: #{created.length}"
      created.each { |str| log "    + #{str}" }
      log "  Deleted: #{deleted.length}"
      deleted.each { |str| log "    - #{str}" }
    end
  end
end
