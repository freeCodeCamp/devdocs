require 'io/console'

module Docs
  # Writes a progress bar to the terminal, rewriting the same line as it moves
  # forward. (This used to be the progress_bar gem, which comes with highline
  # and options for what amounts to one line of output.)
  class ProgressBar
    # Seconds between two writes, so that a fast scraper doesn't spend its time
    # drawing the bar.
    INTERVAL = 0.2
    FALLBACK_WIDTH = 80

    attr_accessor :max
    attr_reader :count

    def initialize(max = 100)
      @max = max
      @count = 0
      @start = Time.now
      @last_write = Time.at(0)
    end

    def increment!(count = 1)
      @count += count
      write if Time.now - @last_write > INTERVAL || @count >= max
    end

    def write
      @last_write = Time.now
      $stderr.print "\r#{self}"
    end

    def to_s
      meters = [counter, percentage, elapsed, eta].join(' ')
      "#{bar(terminal_width - meters.length - 1)} #{meters}"
    end

    private

    def ratio
      # Nothing to do is as done as it gets; dividing by it would give NaN.
      return 1.0 if max.zero?
      [count.to_f / max, 1.0].min
    end

    def bar(width)
      return '' if width < 2
      progress = (ratio * (width - 2)).floor
      "[#{'#' * progress}#{' ' * (width - 2 - progress)}]"
    end

    def counter
      "[%#{max.to_s.length}i/%i]" % [[count, max].min, max]
    end

    def percentage
      '[%3i%%]' % (ratio * 100)
    end

    def elapsed
      "[#{format_interval(Time.now - @start)}]"
    end

    def eta
      remaining = [max - count, 0].max
      "[#{format_interval(count > 0 ? remaining * (Time.now - @start) / count : 0)}]"
    end

    def format_interval(seconds)
      '%02i:%02i:%02i' % [seconds / 3600, seconds % 3600 / 60, seconds % 60]
    end

    def terminal_width
      $stderr.winsize.last
    rescue SystemCallError, NoMethodError
      FALLBACK_WIDTH
    end
  end
end
