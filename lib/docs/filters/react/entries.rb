module Docs
  class React
    class EntriesFilter < Docs::EntriesFilter
      API_SLUGS = %w(
        top-level-api
        component-api
        component-specs
      )

      def get_name
        at_css('h1').child.content
      end

      def get_type
        link = at_css('.nav-docs-section .active')
        section = link.ancestors('.nav-docs-section').first
        section.at_css('h3').content
      end

      def additional_entries
        return [] unless API_SLUGS.include?(slug)

        css('.inner-content h3, .inner-content h4').map do |node|
          name = node.content
          name.remove! %r{[#\(\)]}
          name.remove! %r{\w+\:}
          id = node.at_css('.anchor')['name']
          type = slug.include?('component') ? 'Component' : 'React'
          [name, id, type]
        end
      end
    end
  end
end
