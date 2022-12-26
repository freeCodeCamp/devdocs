module Docs
  class Nuxtjs
    class ContainerFilter < Filter
      def call
          at_css '.docus-content'
      end
    end
  end
end
