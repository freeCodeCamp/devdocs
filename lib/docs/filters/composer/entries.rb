module Docs
  class Composer
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        title = at_css('h1').content
        title = "#{Integer(subpath[1]) + 1}. #{title}" if type == 'Book'
        title
      end

      def get_type
        return 'Articles' if subpath.start_with?('articles/')
        'Book'
      end

      def additional_entries
        entries = []

        if subpath == '04-schema.md' # JSON Schema
            css('h3').each do |node|
              name = node.content.strip
              name.remove!(' (root-only)')
              entries << [name, node['id'], 'JSON Schema']
            end
        end

        if subpath == '06-config.md' # Composer config
            css('h2').each do |node|
              entries << [node.content.strip, node['id'], 'Configuration Options']
            end
        end

        entries
      end
    end
  end
end
