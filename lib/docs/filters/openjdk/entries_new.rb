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
        entries = []

        css('section[id]').each do |node|
          next if !(node['id'].match?(/\(/))
          entries << [self.name+ '.' +node.at_css('h3').content + '()', node['id']]
        end

        entries
      end

    end
  end
end
