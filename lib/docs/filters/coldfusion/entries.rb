module Docs
  class Coldfusion
    class EntriesFilter < Docs::EntriesFilter
      # Category/listing slugs that aggregate other entries and must not appear
      # as entries themselves. Categories generally end in "-functions" or
      # "-tags", but list the fixed index pages explicitly.
      INDEX_SLUGS = %w(index tags functions all).freeze

      def include_default_entry?
        entry_page?
      end

      def get_name
        if (h1 = at_css('#docname'))
          h1.content.strip
        elsif (h1 = at_css('h1'))
          # Guide pages: use the heading text without anchor noise.
          h1.content.strip
        else
          super
        end
      end

      def get_type
        return 'Guides' if guide_page?

        # Use the second breadcrumb link (Tags / Functions) as the category.
        crumb = css('.breadcrumb a').map { |a| a.content.strip }
        if crumb.include?('Tags')
          'Tags'
        elsif crumb.include?('Functions')
          'Functions'
        else
          'Guides'
        end
      end

      private

      # A real reference entry: a tag or function page. These have a `data-doc`
      # whose value matches the slug (no spaces) and usually a `#syntax` block.
      def entry_page?
        return false if index_slug?
        return true if guide_page?

        doc_name = at_css('[data-doc]').try(:[], 'data-doc')
        return false if doc_name.nil?
        # Category pages have human titles with spaces (e.g. "String Functions").
        !doc_name.include?(' ')
      end

      def guide_page?
        # Guides have no breadcrumb but do have content; they are neither tags
        # nor functions nor category indexes.
        return false if index_slug?
        at_css('.breadcrumb').nil? && at_css('h1')
      end

      def index_slug?
        s = slug.to_s.downcase
        return true if INDEX_SLUGS.include?(s)
        s.end_with?('-functions', '-tags')
      end
    end
  end
end
