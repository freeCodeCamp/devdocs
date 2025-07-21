module Docs
  class Rust
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        if slug.start_with?('book') || slug.start_with?('reference')
          name = at_css("h2", "h1")
          ch1 = slug[/ch(\d+)-(\d+)/, 1]
          ch2 = slug[/ch(\d+)-(\d+)/, 2]
          name ? "#{ch1}.#{ch2}. #{name.content}" : 'Introduction'
        elsif slug == 'error-index'
          'Compiler Errors'
        else
          at_css('main h1').at_css('button')&.remove
          name = at_css('main h1').content.remove(/\A.+\s/).remove('⎘')
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
          heading = at_css('main h1').content.strip
          if path.length > 2 || (path.length == 2 && (heading.start_with?('Module') || heading.start_with?('Primitive')))
            path[0..1].join('::')
          else
            path[0]
          end
        end
      end

      def additional_entries
        if slug.start_with?('book') || slug.start_with?('reference')
          []
        elsif slug == 'error-index'
          css('.error-described h2.section-header').each_with_object [] do |node, entries|
            entries << [node.content, node['id']] unless node.content.include?('Note:')
          end
        else
          css('.method')
            .each_with_object({}) { |node, entries|
              name = node.at_css('a.fn').try(:content)
              next unless name
              name.prepend "#{self.name}::"
              entries[name] ||= [name, node['id']]
            }.values
        end
      end

    end
  end
end
