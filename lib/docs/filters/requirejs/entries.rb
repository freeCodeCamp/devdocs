module Docs
  class Requirejs
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        'Guides'
      end

      def additional_entries
        return [] unless root_page?

        entries = []
        type = nil

        css('*').each do |node|
          if node.name == 'h2'
            type = node.content
          elsif node.name == 'h3' || node.name == 'h4'
            entries << [node.content, node['id'], type]
          end
        end

        css('p[id^="config-"]').each do |node|
          next if node['id'].include?('note')
          entries << [node.at_css('strong').content, node['id'], 'Configuration Options']
        end

        entries
      end
    end
  end
end
