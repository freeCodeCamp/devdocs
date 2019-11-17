module Docs
  class Latex
    class EntriesFilter < Docs::EntriesFilter

      @@entries = Hash.new

      def initialize(*)
        super

        return unless root_page?

        css('.contents > ul > li').each do |node|
          lev1 = node.at_css('> a:first-child').text.sub /^[0-9A-Z]+(\.[0-9]+)* /, ''
          node.css('a').each do |link|
            href = link['href'].split('#')[0].parameterize.downcase
            @@entries[href] = lev1
          end
        end

      end

      def get_name
        at_css('h1, h2, h3, h4, h5, h6').content.sub /^[0-9A-Z]+(\.[0-9]+)* /, ''
      end

      def get_type
        begin
          return @@entries[slug.downcase]
        rescue
          return "Missing type with slug #{slug}"
        end
      end

      def include_default_entry?
        true
      end

      def additional_entries
        return []
      end

      private

    end
  end
end
