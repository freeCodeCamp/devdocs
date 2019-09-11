module Docs
  class Cordova
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        return 'CLI' if slug == 'reference/cordova-cli/index'
        name = at_css('#page-toc-source').at_css('h1, h2').content.strip
        name.remove! ' Guide'
        name
      end

      def get_type
        return 'Platforms' if subpath.include?('guide/platforms/')
        return 'Plugins' if name.start_with?('cordova-plugin')
        at_css('.site-toc .this-page').ancestors('li').last.at_css('span').content
      end

      def additional_entries
        case slug
        when 'reference/cordova-cli/index'
          css('#page-toc-source h2').each_with_object [] do |node, entries|
            name = node.content.strip
            id = name.parameterize
            next unless name =~ /cordova .+ command/
            name.remove! ' command'
            entries << [name, id, 'Reference: CLI']
          end
        when 'config_ref/index'
          namespace = ''
          css('#page-toc-source > *').each_with_object [] do |node, entries|
            case node.name
            when 'h1'
              name = node.content.strip
              next unless name =~ /\A[a-z]+\z/
              entries << ["<#{name}>", name.parameterize, 'Reference: config.xml']
            when 'h2'
              name = node.content.strip
              next unless name =~ /\A[a-z]+\z/
              namespace = name
              entries << ["<#{name}>", name.parameterize, 'Reference: config.xml']
            when 'h3'
              name = node.content.strip
              next unless name =~ /\A[a-z]+\z/
              entries << ["<#{namespace}> <#{name}>", name.parameterize, 'Reference: config.xml']
            end
          end
        when 'cordova/events/events'
          css('#page-toc-source h2').each_with_object [] do |node, entries|
            name = node.content.strip
            id = name.parameterize
            next unless name =~ /\A[a-z]+\z/
            entries << [name, id, 'Reference: events']
          end
        else
          []
        end
      end
    end
  end
end
