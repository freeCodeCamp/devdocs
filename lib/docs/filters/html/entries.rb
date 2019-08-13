module Docs
  class Html
    class EntriesFilter < Docs::EntriesFilter
      OBSOLETE = %w(frame frameset hgroup noframes)
      ADDITIONAL_ENTRIES = { 'Element/Heading_Elements' => (1..6).map { |n| ["h#{n}"] } }

      def get_name
        name = super
        name.sub!('Element.', '').try(:downcase!)
        name.sub!('Global attributes.', '').try(:concat, ' (attribute)')
        name.sub!(/input.(\w+)/, 'input type="\1"')
        name
      end

      def get_type
        return 'Miscellaneous' if slug.include?('CORS') || slug.include?('Using')

        if slug.start_with?('Global_attr')
          'Attributes'
        elsif at_css('.obsoleteHeader', '.deprecatedHeader', '.nonStandardHeader') || OBSOLETE.include?(slug.remove('Element/'))
          'Obsolete'
        elsif slug.start_with?('Element/')
          'Elements'
        else
          'Miscellaneous'
        end
      end

      def include_default_entry?
        return false if %w(Element/Heading_Elements).include?(slug)
        (node = doc.at_css '.overheadIndicator, .blockIndicator').nil? || node.content.exclude?('not on a standards track')
      end

      def additional_entries
        return ADDITIONAL_ENTRIES[slug] if ADDITIONAL_ENTRIES.key?(slug)

        if slug == 'Attributes'
          css('.standard-table td:first-child').each_with_object [] do |node, entries|
            next if node.next_element.content.include?('Global attribute')
            name = "#{node.content.strip} (attribute)"
            id = node.parent['id'] = name.parameterize
            entries << [name, id, 'Attributes']
          end
        elsif slug == 'Link_types'
          css('.standard-table td:first-child > code').map do |node|
            name = node.content.strip
            id = node.parent.parent['id'] = name.parameterize
            name.prepend 'rel: '
            [name, id, 'Attributes']
          end
        else
          []
        end
      end
    end
  end
end
