module Docs
  class Dojo
    class CleanUrlsFilter < Filter
      def call
        html.remove! '?xhr=true'
        html
      end
    end
  end
end
