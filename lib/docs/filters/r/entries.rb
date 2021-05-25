module Docs
  class R
    class EntriesFilter < Docs::EntriesFilter

      @@include_manual = false
      @@include_misc = false

      def initialize(*)
        super
      end

      def slug_parts
        slug.split('/')
      end

      def is_package?
        slug_parts[0] == 'library'
      end

      def is_manual?
        slug_parts[-2] == 'manual'
      end

      def get_name
        return slug_parts[3] + ' − ' + at_css('h2').content if is_package?
        title = at_css('h1.settitle')
        title ? title.content : at_css('h1, h2').content
      end

      def get_type
        return slug_parts[1] if is_package?
        return at_css('h1.settitle').content if is_manual?
        'Miscellaneous'
      end

      def include_default_entry?
        if is_manual? or slug_parts[-1] == '00Index' or slug_parts[-1] == 'index'
          return false
        end
        is_package? or self.include_misc
      end

      def additional_entries
        return [] unless is_manual? and self.include_manual

        entries = []
        css('div.contents > ul > li').each do |node|
          node.css('a').each do |link|
            link_name = link.content.sub /^[0-9A-Z]+(\.[0-9]+)* /, ''
            entries << [link_name, link['href'].split('#')[1], name]
          end
        end
        return entries
      end

      private
    end
  end
end
