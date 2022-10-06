module Docs
  class Fastapi
    class ContainerFilter < Filter
      def call
        at_css '.md-content > .md-content__inner'
      end
    end
  end
end
