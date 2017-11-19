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
        'Progression migration': %(),
        'Deferred migration': %(),
        'Environment variables': %(),
        "Beginner's Guide": %w(),
        'Error management configuration': %w(),
        'Anti-patterns': %w(),
        'Deprecated APIs': %w()
      }

      def get_name
        name = at_css('h1.post-title')
        if name.nil?
          name = at_css('.post-content h2')
        end
        name.text
      end

      def get_type
        type = nil
        TYPE_MAP.each do |k,v|
          if k.to_s.casecmp(name.strip) == 0
            type = k
            break
          else
            slug_end = slug.sub(%r(^docs/api/), '')
            if v.include?(slug_end.downcase)
              type = k
              break
            end
          end
        end

        type.to_s
      end

    end
  end
end
