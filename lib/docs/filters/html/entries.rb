module Docs
  class Html
    class EntriesFilter < Docs::EntriesFilter
      HTML5 = %w(content element video)
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
        slug = self.slug.remove('Element/')

        if self.slug.start_with?('Global_attr')
          'Attributes'
        elsif at_css('.obsoleteHeader', '.deprecatedHeader', '.nonStandardHeader') || OBSOLETE.include?(slug)
          'Obsolete'
        else
          spec = css('.standard-table').last.try(:content)
          if (spec && html5_spec?(spec)) || HTML5.include?(slug)
            'HTML5'
          else
            if self.slug.start_with?('Element/')
              'Standard'
            else
              'Miscellaneous'
            end
          end
        end
      end

      def include_default_entry?
        return false if %w(Element/Heading_Elements).include?(slug)
        (node = doc.at_css '.overheadIndicator').nil? || node.content.exclude?('not on a standards track')
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

      def html5_spec?(spec)
        (spec =~ /HTML\s?5/ || spec.include?('WHATWG HTML Living Standard')) && spec !~ /HTML\s?4/
      end
    end
  end
end
