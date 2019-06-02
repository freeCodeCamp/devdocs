module Docs
  class Webpack
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.sub! ' - ', ': '
        name
      end

      TYPE_BY_DIRECTORY = {
        'concepts'      => 'Concepts',
        'guides'        => 'Guides',
        'api'           => 'API',
        'configuration' => 'Configuration',
        'loaders'       => 'Loaders',
        'plugins'       => 'Plugins'
      }

      def get_type
        TYPE_BY_DIRECTORY[slug.split('/').first]
      end

      def additional_entries
        if slug.start_with?('configuration')
          css('h2[id] code').each_with_object [] do |node, entries|
            next if node.previous.try(:content).present?
            entries << [node.content, node.parent['id']]
          end
        elsif slug.start_with?('api') && slug != 'api/parser'
          css('.header[id] code').each_with_object [] do |node, entries|
            next if node.previous.try(:content).present? || node.next.try(:content).present?
            name = node.content.sub(/\(.*\)/, '()')
            name.prepend "#{self.name.split(':').first}: "
            entries << [name, node.parent['id']]
          end
        else
          []
        end
      end
    end
  end
end

