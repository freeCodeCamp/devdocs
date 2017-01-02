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
        entries = []

        css('.inner-content h3 code, .inner-content h4 code').each do |node|
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

        css('.apiIndex a pre').each do |node| # relay
          next unless node.parent['href'].start_with?('#')
          id = node.parent['href'].remove('#')
          name = node.content.strip
          sep = name.start_with?('static') ? '.' : '#'
          name.remove! %r{(abstract|static) }
          name.sub! %r{\(.*\)}, '()'
          name.prepend(self.name + sep)
          entries << [name, id]
        end

        entries
      end
    end
  end
end
