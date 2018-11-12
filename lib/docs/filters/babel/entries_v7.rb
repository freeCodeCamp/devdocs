module Docs
  class Babel
    class EntriesV7Filter < Docusaurus::EntriesFilter
      def get_type
        type = super
        return type unless type.nil?
        if subpath.start_with? 'babel-preset'
          'Presets'
        elsif subpath.start_with? 'babel-plugin'
          'Plugins'
        elsif subpath.in? %w{babel-standalone babel-runtime-corejs2}
          'Tooling'
        else
          raise "Unknown type for page: #{current_url} (subpath: #{subpath})"
        end
      end
      def additional_entries
        []
        # TODO: this method no longer works.
        # return [] unless slug.include?('api')
        #
        # css('h2').each_with_object [] do |node, entries|
        #   name = node.content.strip
        #   next unless name.start_with?('babel.')
        #   name.sub! %r{\(.*}, '()'
        #   entries << [name, node['id']]
        # end
      end
    end
  end
end
