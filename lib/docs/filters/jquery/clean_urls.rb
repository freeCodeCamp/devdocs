module Docs
  class Jquery
    class CleanUrlsFilter < Filter
      def call
        html.gsub! 'local.api.jquery', 'api.jquery'
        html
      end
    end
  end
end
