module Docs
  class Screeps
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        title_node = at_css('h1.article-title')
        title_node.nil? ? "API Reference" : title_node.content
      end

      def get_type
        title_node = at_xpath('//a[@class="sidebar-link current"]/preceding::strong[1]')
        title_node.nil? ? "API Reference" : "Manual: #{title_node.content}"
      end

      def additional_entries
        # Only extract entries from the API reference
        return [] if subpath != 'api/'

        entries = []

        # Classes
        css('h2[id]').each do |node|
          id = node['id']
          entries << [id, id, id]
        end

        # Class members
        css('h3[id].api-property').each do |node|
          id = node['id']
          entry_type = id.split('.')[0..-2].join('.')
          entries << [id, id, entry_type]
        end

        entries
      end
    end
  end
end
