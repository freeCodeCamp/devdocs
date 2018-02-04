module Docs
  class Babel
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        if subpath.start_with?('plugins/preset')
          'Presets'
        elsif subpath.start_with?('plugins/transform')
          'Transform Plugins'
        elsif subpath.start_with?('plugins/minify')
          'Minification'
        elsif subpath.start_with?('plugins/syntax')
          'Syntax Plugins'
        elsif subpath.start_with?('plugins')
          'Plugins'
        elsif subpath.start_with?('usage/')
          'Usage'
        elsif subpath.start_with?('core-packages/')
          'Core Packages'
        else
          'Miscellaneous'
        end
      end

      def additional_entries
        return [] unless slug.include?('api')

        css('h2').each_with_object [] do |node, entries|
          name = node.content.strip
          next unless name.start_with?('babel.')
          name.sub! %r{\(.*}, '()'
          entries << [name, node['id']]
        end
      end
    end
  end
end
