module Docs
  class Angular
    class CleanUrlsFilter < Filter
      def call
        html.gsub! 'angularjs.org/1.3.1/docs/partials/api/', 'angularjs.org/1.3.1/docs/api/'
        html.gsub! %r{angularjs.org/1.3.1/docs/api/(.+?)\.html}, 'angularjs.org/1.3.1/docs/api/\1'
        html
      end
    end
  end
end
