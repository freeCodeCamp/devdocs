module Docs
  class Dojo
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.remove(/\(.*\)/).remove('dojo/').strip
      end

      def get_type
        path = name.split(/[\/\.\-]/)
        path[0] == '_base' ? path[0..1].join('/') : path[0]
      end

      def additional_entries
        entries = []

        css('.jsdoc-summary-list li.functionIcon:not(.private):not(.inherited) > a').each do |node|
          entries << ["#{self.name}##{node.content}()", node['href'].remove('#')]
        end

        css('.jsdoc-summary-list li.objectIcon:not(.private):not(.inherited) > a').each do |node|
          entries << ["#{self.name}##{node.content}", node['href'].remove('#')]
        end

        entries
      end
    end
  end
end
