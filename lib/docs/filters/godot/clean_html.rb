module Docs
  class Godot
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.document .section')

        doc
      end
    end
  end
end
