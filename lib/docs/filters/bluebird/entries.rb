module Docs
  class Bluebird
    class EntriesFilter < Docs::EntriesFilter
      TYPE_MAP = {
        Core: %w(new-promise then spread catch error finally bind promise.join
          promise.try promise.method promise.resolve promise.reject core
          promise.bind),
        'Synchronous inspection': %w(promiseinspection isfulfilled isrejected
          ispending iscancelled value reason),
        Collections: %w(promise.all promise.props promise.any promise.some
          promise.map promise.reduce promise.filter promise.each
          promise.mapseries promise.race all props any some map reduce filter
          each mapseries),
        'Resource management': %w(promise.using disposer),
        Promisification: %w(promise.promisify promise.promisifyall
          promise.fromcallback ascallback),
        Timers: %w(delay timeout promise.delay),
        Cancellation: %w(cancel),
        Generators: %w(promise.coroutine promise.coroutine.addyieldhandler),
        Utility: %w(tap tapcatch call get return throw catchreturn catchthrow
          reflect promise.getnewlibrarycopy promise.noconflict
          promise.setscheduler),
        'Built-in error types': %w(operationalerror timeouterror
          cancellationerror aggregateerror),
        Configuration: %w(global-rejection-events local-rejection-events
          done promise.config suppressunhandledrejections
          promise.onpossiblyunhandledrejection promise.bind
          promise.onunhandledrejectionhandled),
      }

      def get_name
        name = at_css('h1').content.strip
        name << '()' if doc.to_html.include?("#{name}(")
        name
      end

      def get_type
        if slug.start_with?('api')
          TYPE_MAP.each do |key, value|
            return key.to_s if value.include?(slug.remove('api/'))
          end
        else
          'Guides'
        end
      end
    end
  end
end
