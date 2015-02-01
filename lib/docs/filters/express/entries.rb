module Docs
  class Express
    class EntriesFilter < Docs::EntriesFilter
      TYPES_BY_PATH = {
        'starter' => 'Getting started',
        'guide' => 'Guide',
        'advanced' => 'Guide'
      }

      def get_name
        at_css('h1').content
      end

      def get_type
        TYPES_BY_PATH[slug.split('/').first]
      end

      def additional_entries
        return [] unless root_page?
        type = 'Application'

        doc.children.each_with_object [] do |node, entries|
          if node.name == 'h2'
            type = node.content
            entries << [type, node['id'], 'Application'] if type == 'Middleware'
            next
          elsif node.name == 'h3'
            next if type == 'Middleware'
            name = node.content.strip
            name.sub! %r{\(.+\)}, '()'

            entries << [name, node['id'], type]
          end
        end
      end
    end
  end
end
