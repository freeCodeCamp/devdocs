module Docs
  class Openjdk
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('.header > .title').content.strip
        name.remove! 'Package '
        name.remove! 'Class '
        name.remove! 'Interface '
        name.remove! 'Annotation Type '
        name.remove! 'Enum '
        name.remove! %r{<.*}
        name
      end

      def get_type
        if subtitle = at_css('.header > .subTitle:last-of-type')
          subtitle.content.strip
        else
          at_css('.header > .title').content.strip.remove 'Package '
        end
      end

      def additional_entries
        # Only keep the first found entry with a unique name,
        # i.e. overloaded methods are skipped in index
        css('a[name$=".summary"]').each_with_object({}) do |summary, entries|
          next if summary['name'] == 'nested.class.summary'
          summary.parent.css('.memberNameLink a').each do |node|
            entry_name = node.parent.parent.content.strip
            entry_name.sub! %r{\(.+?\)}m, '()'
            id = node['href']
            id.remove! %r{.*#}
            entries[entry_name] ||= [name + '.' + entry_name, id]
          end
        end.values
      end
    end
  end
end
