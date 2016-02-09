module Docs
  class Tensorflow
    class CleanHtmlFilter < Filter
      def call
        css('hr').remove
        doc
      end
    end
  end
end
