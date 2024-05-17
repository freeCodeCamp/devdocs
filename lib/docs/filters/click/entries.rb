module Docs
  class Click
    class EntriesFilter < Docs::EntriesFilter

      def initialize(*)
        super
      end

      def get_name
        return at_css('h1').content.strip
      end

      def get_type
        return at_css('h1').content.strip
      end

      def include_default_entry?
        false
      end

      def additional_entries
        return [] if root_page?

        if slug == 'api/'
          entries = []
          doc.css('> section').each do |section|
            title = section.at_css('h2').content.strip
            section.css('> dl.py > dt[id]').each do |dt|
              entries << [dt['id'], dt['id'], title]
            end
          end
          return entries
        end

        (doc.css('> section') || []).map do |section|
          title = section.at_css('h2').content.strip
          [title, section['id']]
        end
      end

      private

    end
  end
end
