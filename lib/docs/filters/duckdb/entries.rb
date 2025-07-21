module Docs
  class Duckdb
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1', '.title').content
      end

      def get_type
        case subpath
        when /\Asql\//
          'SQL Reference'
        when /\Aapi\//
          'Client APIs'
        when /\Aguides\//
          'How-to Guides'
        when /\Adata\//
          'Data Import'
        when /\Aoperations_manual\//
          'Operations Manual'
        when /\Adev\//
          'Development'
        when /\Ainternals\//
          'Internals'
        when /\Aextensions\//
          'Extensions'
        when /\Aarchive\//
          'Archive'
        else
          'Documentation'
        end
      end

      def additional_entries
        entries = []
        css('h2[id]', 'h3[id]').each do |node|
          name = node.content.strip
          # Clean up the name
          name = name.gsub(/[\r\n\t]/, ' ').squeeze(' ')
          entries << [name, node['id'], get_type]
        end
        entries
      end
    end
  end
end