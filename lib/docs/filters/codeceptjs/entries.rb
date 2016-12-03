module Docs
  class Codeceptjs
    class EntriesFilter < Docs::EntriesFilter
      def get_name
          (at_css('h1') || at_css('h2')).content
      end

      def get_type
          return "Reference" if %w(commands configuration reports translation).include? subpath.scan(/\w+/).first
          return "Guides" unless slug.camelize =~ /Helpers::.+/
          "Helpers::" + (at_css('h1') || at_css('h2')).content
      end

      def additional_entries
        return [] unless type =~ /Helpers::.*/

        helper = type.sub(/Helpers::/, '')+ '::'

        css('h2').map do |node|
          next if node['id'] == 'access-from-helpers'
          [helper + node.content, node['id']]
        end.compact
      end

    end
  end
end
