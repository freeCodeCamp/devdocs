module Docs
  class Koa
    class EntriesFilter < Docs::EntriesFilter
      @root_type = 'Koa'
      def get_name
        at_css('h1').content
      end

      def additional_entries
        return [] unless slug.match?(/^api/)
        type = get_name
        css('h2, h3').to_a
          .delete_if do |node|
            node.content == 'API' ||
              (slug.include?('index') && !node.content.include?('.'))
          end
          .map do |node|
            name = node.content.strip.sub(/\(.*\)\z/, '()')
            type = 'API' if type == @root_type && name.include?('.')
            [name, node['id'], type]
          end
      end

      def get_type
        case slug
        when /^api\/index/
          'API'
        when /^api/
          get_name
        else
          'Guides'
        end
      end
    end
  end
end
