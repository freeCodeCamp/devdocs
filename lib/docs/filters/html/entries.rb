module Docs
  class Html
    class EntriesFilter < Docs::EntriesFilter
      HTML5 = %w(menuitem)
      OBSOLETE = %w(frame frameset hgroup noframes)
      ADDITIONAL_ENTRIES = {
        'Heading_Elements' => [%w(h1), %w(h2), %w(h3), %w(h4), %w(h5), %w(h6)] }

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
