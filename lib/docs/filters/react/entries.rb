module Docs
  class React
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('article h1').content.sub(' (Experimental)', '')
      end

      def get_type
        return 'API Reference' if slug == 'legacy-context'
        return 'Glossary' if slug == 'glossary'
        link = css("nav a[href='#{result[:path].split('/').last}']").last
        return 'Miscellaneous' unless link
        type = link.ancestors('ul').last.previous_element.content
        type.remove! %r{\s*\(.*\)}
        if type == 'Concurrent Mode'
          type + ' (Experimental)' # TODO: Remove when CM is stable
        else
          type
        end
      end

      def additional_entries
        entries = []

        is_glossary = slug == 'glossary'
        css(is_glossary ? 'article h2, article h3' : 'article h3 code, article h4 code').each do |node|
          next if !is_glossary && node.previous.try(:content).present?
          next if slug == 'testing-recipes'
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
          elsif slug == 'test-utils'
            'Reference: Test Utilities'
          elsif slug == 'glossary'
            'Glossary'
          else
            'Reference'
          end
          entries << [name, node['id'] || node.ancestors('[id]').first['id'], type]
        end

        entries
      end
    end
  end
end
