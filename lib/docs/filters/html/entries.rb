module Docs
  class Html
    class EntriesFilter < Docs::EntriesFilter
      HTML5 = %w(content element menuitem template)
      OBSOLETE = %w(frame frameset hgroup noframes)
      ADDITIONAL_ENTRIES = { 'Heading_Elements' => (1..6).map { |n| ["h#{n}"] } }

      def get_name
        super.downcase
      end

      def get_type
        if at_css('.obsoleteHeader', '.deprecatedHeader', '.nonStandardHeader') || OBSOLETE.include?(slug)
          'Obsolete'
        else
          spec = css('.standard-table').last.try(:content)
          if (spec && spec =~ /HTML\s?5/ && spec !~ /HTML\s?4/) || HTML5.include?(slug)
            'HTML5'
          else
            'Standard'
          end
        end
      end

      def include_default_entry?
        slug != 'Heading_Elements'
      end

      def additional_entries
        ADDITIONAL_ENTRIES[slug] || []
      end
    end
  end
end
