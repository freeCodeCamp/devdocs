module Docs
  class Angular
    class CleanUrlsFilter < Filter
      def call
        html.gsub! 'angularjs.org/partials/api/', 'angularjs.org/api/'
        html.gsub! %r{angularjs.org/api/(.+?)\.html}, 'angularjs.org/api/\1'
        html
      end
    end
  end
end
