module Docs
  class Codeceptjs
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        if subpath == 'helpers/'
          'Helpers'
        elsif subpath.start_with?('helpers')
          "Helpers: #{name}"
        elsif subpath.in? %w(commands/ configuration/ reports/ translation/)
          'Reference'
        else
          'Guide'
        end
      end

      def additional_entries
        return [] unless subpath.start_with?('helpers') && subpath != 'helpers/'

        css('h2, h3').each_with_object [] do |node, entries|
          next if node['id'] == 'access-from-helpers' || node.content !~ /\s*[a-z_]/
          entries << ["#{node.content} (#{name})", node['id']]
        end
      end
    end
  end
end
