require 'active_support/notifications'

module Docs
  module Instrumentable
    def self.extended(base)
      base.send :extend, Methods
    end

    def self.included(base)
      base.send :include, Methods
    end

    module Methods
      def instrument(*args, &block)
        ActiveSupport::Notifications.instrument(*args, &block)
      end

      def subscribe(*args, &block)
        ActiveSupport::Notifications.subscribe(*args, &block)
      end
    end
  end
end
