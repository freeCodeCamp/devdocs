module Docs
  class React
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('article h1').content
      end

      def get_type
        link = css("nav a[href='#{result[:path].split('/').last}']").last
        return 'Miscellaneous' unless link
        type = link.ancestors('ul').last.previous_element.content
        type.remove! %r{\s*\(.*\)}
        type
      end

      def additional_entries
        entries = []

        css('article h3 code, article h4 code').each do |node|
          next if node.previous.try(:content).present?
          name = node.content.strip
          # name.remove! %r{[#\(\)]}
          # name.remove! %r{\w+\:}
          # name.strip!
          # name = 'createFragmentobject' if name.include?('createFragmentobject')
          type = if slug == 'react-component'
            'Reference: Component'
          elsif slug == 'react-api'
            'Reference: React'
          elsif slug == 'hooks-reference'
            'Hooks'
          else
            'Reference'
          end
          entries << [name, node.parent['id'], type]
        end

        entries
      end
    end
  end
end
