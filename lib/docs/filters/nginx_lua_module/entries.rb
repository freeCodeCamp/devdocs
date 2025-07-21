module Docs
  class NginxLuaModule
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []

        css('h2:contains("Directives") + ul > li > a').each do |node|
          entries << [node.content, node['href'].remove('#'), 'Directives']
        end

        css('h2:contains("Nginx API for Lua") + ul > li > a').each do |node|
          next if node.content == 'Introduction'
          entries << [node.content, node['href'].remove('#'), 'Nginx API for Lua']
        end

        entries
      end
    end
  end
end
