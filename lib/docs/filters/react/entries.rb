module Docs
  class React
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').children.select(&:text?).map(&:content).join.strip
      end

      def get_type
        link = at_css('.nav-docs-section .active, .toc .active')
        return 'Miscellaneous' unless link
        section = link.ancestors('.nav-docs-section, section').first
        type = section.at_css('h3').content.strip
        type
      end

      def additional_entries
        css('.inner-content h3 code, .inner-content h4 code').each_with_object([]) do |node, entries|
          name = node.content
          name.remove! %r{[#\(\)]}
          name.remove! %r{\w+\:}
          name.strip!
          name = 'createFragmentobject' if name.include?('createFragmentobject')
          id = node.parent.at_css('.anchor')['name']
          type = if slug == 'react-component'
            'Reference: Component'
          elsif slug == 'react-api'
            'Reference: React'
          else
            'Reference'
          end
          entries << [name, id, type]
        end
      end
    end
  end
end
