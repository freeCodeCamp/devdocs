# frozen_string_literal: true

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
        return 'Packages' if slug.end_with?('package-summary')

        if subtitle = at_css('.header > .subTitle:last-of-type')
          type = subtitle.content.strip
        else
          type = at_css('.header > .title').content.strip.remove 'Package '
        end
        type = type.split('.')[0..2].join('.')
        type
      end

      def additional_entries
        entries = []

        css('.memberNameLink a').each do |node|
          next unless node['href'].match?(/[-(]/) # skip non-methods

          if (version=='8' || version == '8 GUI' || version == '8 Web')
            id = node['href'].gsub(/.*#/, '')
          else
            id = slug.downcase + node['href']
          end

          entries << [self.name + '.' + node.content + '()', id]
        end

        entries

      end

    end
  end
end
