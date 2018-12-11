module Docs
  class Pony
    class ContainerFilter < Filter
      def call
        css('article')
      end
    end
  end
end
