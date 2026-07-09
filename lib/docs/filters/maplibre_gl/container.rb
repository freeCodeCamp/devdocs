module Docs
  class MaplibreGl
    class ContainerFilter < Filter
      def call
        at_css '.md-content__inner'
      end
    end
  end
end
