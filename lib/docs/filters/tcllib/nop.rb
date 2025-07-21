module Docs
  class Tcllib
    class NopFilter < Filter
      def call
        doc
      end
    end
  end
end
