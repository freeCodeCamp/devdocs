module Docs
  class Redux
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        name = at_css('h1').content
        name.gsub(/\(.*\)/, '()')
      end

      def get_type
        slug.match?(/\Astore\Z/) ? 'Store API' : 'Top-Level Exports'
      end

      def additional_entries
        entries = []

        if slug.match?(/\Astore\Z/)
          css('h3').each do |node|
            entry_path = node.content.gsub(/\(|\)/, '')
            entry_name = node.content.gsub(/\(.*\)/, '()')
            entries << [entry_name, entry_path.downcase, 'Store API']
          end
        end

        entries
      end

    end
  end
end
