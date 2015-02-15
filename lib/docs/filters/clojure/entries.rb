module Docs
  class Clojure
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        slug.remove('-api')
      end

      def get_type
        'Namespaces'
      end

      def additional_entries
        css(".toc-entry-anchor[href^='##{self.name}']").map do |node|
          name = node.content
          id = node['href'].remove('#')
          type = name == 'clojure.core' ? id.split('/').first : self.name
          [name, id, type]
        end
      end
    end
  end
end
