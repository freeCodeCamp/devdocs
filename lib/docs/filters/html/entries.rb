module Docs
  class Html
    class EntriesFilter < Docs::EntriesFilter
      ADDITIONAL_ENTRIES = { 'Element/Heading_Elements' => (1..6).map { |n| ["h#{n}"] } }

      def get_name
        name = super
        name.sub!('Guides.', '')
        name.sub!('How to.', '')
        name.sub!('Reference.Elements.', '').try(:downcase!)
        name.sub!('Reference.Attributes.', '').try(:concat, ' (attribute)')
        name.sub!('Reference.Global attributes.', '').try(:concat, ' (attribute)')
        name.sub!(/input\.([-\w]+)/, 'input type="\1"')
        name
      end

      def get_type
        if at_css('.deprecated', '.non-standard', '.obsolete')
          'Obsolete'
        elsif slug.start_with?('Guides/')
          'Guides'
        elsif slug.start_with?('Reference/')
          slug.split('/').drop(1).first.sub(/_/, ' ')
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
            name = "#{node.at_css('code').content.strip} (attribute)" if node.at_css('code')
            id = node.parent['id'] = name.parameterize
            entries << [name, id, 'Attributes']
          end
        elsif slug == 'Link_types'
          css('.standard-table td:first-child > code').map do |node|
            name = node.content.strip
            name = "#{node.at_css('code').content.strip} (attribute)" if node.at_css('code')
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
