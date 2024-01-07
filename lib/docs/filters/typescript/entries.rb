module Docs
  class Typescript
    class EntriesFilter < Docs::EntriesFilter

      DEPRECATED_PAGES = %w(
        advanced-types
        basic-types
        classes
        functions
        generics
        interfaces
        literal-types
        unions-and-intersections
      )

      def get_name
        return 'TSConfig Reference' if slug == 'tsconfig'
        at_css('h1') ? at_css('h1').content : at_css('h2').content
      end

      def get_type
        if DEPRECATED_PAGES.include? slug
          'Handbook (deprecated)'
        elsif slug.include?('declaration-files')
          'Declaration Files'
        elsif slug == 'download'
          'Handbook'
        elsif slug == 'why-create-typescript'
          'Handbook'
        else
          button = at_css('nav#sidebar > ul > li.open.highlighted > button')
          button ? button.content : name
        end
      end

      def additional_entries
        return [] if DEPRECATED_PAGES.include? slug
        return [] if slug == 'tsconfig-json'
        base_url.path == '/' ? tsconfig_entries : handbook_entries
      end

      def tsconfig_entries
        css('h3 > code').each_with_object [] do |node, entries|
          entries << [node.content, node.parent['id']]
        end
      end

      def handbook_entries
        css('h2', 'h3:has(code)').each_with_object [] do |node, entries|
          entries << ["#{name}: #{node.content}", node['id']] if node['id']
        end
      end

    end
  end
end
