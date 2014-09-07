module Docs
  class Html
    class EntriesFilter < Docs::EntriesFilter
      HTML5 = %w(content element video)
      OBSOLETE = %w(frame frameset hgroup noframes)
      ADDITIONAL_ENTRIES = { 'Element/Heading_Elements' => (1..6).map { |n| ["h#{n}"] } }

      def get_name
        name = super
        name.remove!('Element.').try(:downcase!)
        name
      end

      def get_type
        slug = self.slug.remove('Element/')

        if at_css('.obsoleteHeader', '.deprecatedHeader', '.nonStandardHeader') || OBSOLETE.include?(slug)
          'Obsolete'
        else
          spec = css('.standard-table').last.try(:content)
          if (spec && html5_spec?(spec)) || HTML5.include?(slug)
            'HTML5'
          else
            'Standard'
          end
        end
      end

      def include_default_entry?
        !%w(Attributes Link_types Element/Heading_Elements).include?(slug)
      end

      def additional_entries
        return ADDITIONAL_ENTRIES[slug] if ADDITIONAL_ENTRIES.key?(slug)

        if slug == 'Attributes'
          css('.standard-table td:first-child').map do |node|
            name = node.content.strip
            id = node.parent['id'] = name.parameterize
            [name, id, 'Attributes']
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
