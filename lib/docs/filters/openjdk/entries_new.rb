module Docs
  class Openjdk
    class EntriesNewFilter < Docs::EntriesFilter

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
        return 'Packages' if slug.end_with?('package-summary')
        return 'Modules' if slug.end_with?('module-summary')

        if subtitle = at_css('.header > .sub-title:last-of-type')
          type = subtitle.content.strip
        else
          type = at_css('.header > .title').content.strip.remove 'Package '
          type.remove!('Module ')
        end
        type = type.split('.')[0..2].join('.')
        type
      end

      def additional_entries
        css('a[name$=".summary"]').each_with_object({}) do |summary, entries|
          next if summary['name'].include?('nested') || summary['name'].include?('constructor') ||
                  summary['name'].include?('field') || summary['name'].include?('constant')
          summary.parent.css('.memberNameLink a').each do |node|
            name = node.parent.parent.content.strip
            name.sub! %r{\(.+?\)}m, '()'
            id = node['href'].remove(%r{.*#})
            entries[name] ||= ["#{self.name}.#{name}", id]
          end
        end.values
      end

    end
  end
end
