# frozen_string_literal: true

require 'active_support/subscriber'

module Docs
  class Subscriber < ActiveSupport::Subscriber
    cattr_accessor :namespace

    def self.subscribe_to(notifier)
      attach_to(namespace, new, notifier)
    end

    private

    delegate :puts, :print, :tty?, to: :$stdout

    def log(msg)
      puts "\r" + justify(msg)
    end

    def format_url(url)
      url.to_s.remove %r{\Ahttps?://}
    end

    def format_path(path)
      path.to_s.remove File.join(File.expand_path('.'), '')
    end

    def justify(str)
      return str unless terminal_width
      str = str.dup

      max_length = if tag = str.slice!(/ \[.+\]\z/)
        terminal_width - tag.length
      else
        terminal_width
      end

      str.truncate(max_length).ljust(max_length) << tag.to_s
    end

    def terminal_width
      return @terminal_width if defined? @terminal_width

      @terminal_width = if !tty?
        nil
      elsif ENV['COLUMNS']
        ENV['COLUMNS'].to_i
      else
        `stty size`.scan(/\d+/).last.to_i
      end
    rescue
      @terminal_width = nil
    end
  end
end
