module Docs
  class Rust
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if slug.start_with?('book')
          at_css("#toc a[href='#{File.basename(slug)}']").content
        elsif slug.start_with?('reference')
          'Reference'
        elsif slug == 'error-index'
          'Compiler Errors'
        else
          name = at_css('h1.fqn .in-band').content.remove(/\A.+\s/)
          mod = slug.split('/').first
          name.prepend("#{mod}::") unless name.start_with?(mod)
          name
        end
      end

      PRIMITIVE_SLUG = /\A(\w+)\/(primitive)\./

      def get_type
        if slug.start_with?('book')
          'Guide'
        elsif slug.start_with?('reference')
          'Reference'
        elsif slug == 'error-index'
          'Compiler Errors'
        else
          path = name.split('::')
          heading = at_css('h1.fqn .in-band').content.strip
          if path.length > 2 || (path.length == 2 && (heading.start_with?('Module') || heading.start_with?('Primitive')))
            path[0..1].join('::')
          else
            path[0]
          end
        end
      end

      def additional_entries
        if slug.start_with?('book')
          []
        elsif slug.start_with?('reference')
          css('#TOC > ul > li > a', '#TOC > ul > li > ul > li > a').map do |node|
            name = node.content
            name.sub! %r{(\d)\ }, '\1. '
            name.sub! '10.0.', '10.'
            id = node['href'].remove('#')
            [name, id]
          end
        elsif slug == 'error-index'
          css('.error-described h2.section-header').map do |node|
            [node.content, node['id']]
          end
        else
          css('#methods + * + div > .method', '#required-methods + div > .method', '#provided-methods + div > .method').map do |node|
            name = node.at_css('.fnname').content
            name.prepend "#{self.name}::"
            [name, node['id']]
          end
        end
      end
    end
  end
end
