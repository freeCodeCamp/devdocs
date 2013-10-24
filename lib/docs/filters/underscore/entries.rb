module Docs
  class Underscore
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []
        type = nil

        css('[id]').each do |node|
          # Module
          if node.name == 'h2'
            type = node.content.split.first
            next
          end

          # Method
          node.css('.header', '.alias b').each do |header|
            header.content.split(',').each do |name|
              entries << [name, node['id'], type]
            end
          end
        end

        entries
      end
    end
  end
end
