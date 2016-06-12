module Docs
  class Angularjs
    class CleanUrlsFilter < Filter
      def call
        html.gsub! %r{angularjs\.org/([\d\.]+)/docs/partials/(\w+)/}, 'angularjs.org/\1/docs/\2/'
        html.gsub! %r{angularjs\.org/([\d\.]+)/docs/(\w+)/(.+?)\.html}, 'angularjs.org/\1/docs/\2/\3'
        html
      end
    end
  end
end
