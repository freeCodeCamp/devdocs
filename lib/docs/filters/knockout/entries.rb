module Docs
  class Knockout
    class EntriesFilter < Docs::EntriesFilter
      NAME_BY_SLUG = {
        'custom-bindings'                                 => 'Custom bindings',
        'custom-bindings-controlling-descendant-bindings' => 'Descendant bindings',
        'custom-bindings-for-virtual-elements'            => 'Virtual elements',
        'binding-preprocessing'                           => 'Binding preprocessing',
        'json-data'                                       => 'JSON data',
        'extenders'                                       => 'Extending observables',
        'unobtrusive-event-handling'                      => 'Event handling',
        'fn'                                              => 'Custom functions',
        'ratelimit-observable'                            => 'rateLimit extender',
        'component-overview'                              => 'Component' }

      def get_name
        return NAME_BY_SLUG[slug] if NAME_BY_SLUG.has_key?(slug)
        name = at_css('h1').content.strip
        name.remove! 'The '
        name.sub! %r{"(.+?)"}, '\1'
        name.gsub!(/ [A-Z]/) { |str| str.downcase! }
        name
      end

      def get_type
        if name =~ /observable/i || slug =~ /extender/ || slug == 'computed-dependency-tracking'
          'Observables'
        elsif slug =~ /component/i
          'Components'
        elsif slug.include?('binding') && !name.end_with?('binding')
          'Binding'
        elsif slug.include? 'binding'
          'Bindings'
        elsif slug.include? 'plugin'
          'Plugins'
        else
          'Miscellaneous'
        end
      end
    end
  end
end
