module Docs
  class Pony
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        title = context[:html_title].sub(/ - .*/, '').split(' ').last
        title = "1. #{type}" if title == 'Package'
        title
      end

      def get_type
        subpath.split(/-([^a-z])/)[0][0..-1].sub('-', '/')
      end

      def additional_entries
        return [] if root_page? || name.start_with?("1. ")

        entries = []

        css('h3').each do |node|
          member_name = node.content

          is_field = member_name.start_with?('let ')
          member_name = member_name[4..-1] if is_field

          member_name = member_name.scan(/^([a-zA-Z0-9_]+)/)[0][0]
          member_name += '()' unless is_field

          entries << ["#{name}.#{member_name}", node['id']]
        end

        entries
      end
    end
  end
end
