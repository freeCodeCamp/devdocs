module Docs
  class Moment
    class EntriesFilter < Docs::EntriesFilter
      IGNORE_TYPES = %w(
        Where\ to\ use\ it
        Plugins
        Guides:\ External\ Resources)
      IGNORE_IDS = %w(
        /i18n/loading-into-nodejs/
        /i18n/loading-into-browser/
        /i18n/adding-locale/
        /i18n/getting-locale/
      )

      def get_name
        if subpath == '/guides/'
          'Guides'
        end
      end

      def get_type
        if subpath == '/guides/'
          'Guides'
        end
      end

      def additional_entries
        entries = []
        type = nil

        css('[id]').each do |node|
          if node.name == 'h2'
            type = node.content
            type.remove! ' Guide'
            type.prepend 'Guides: ' if subpath == '/guides/'
            next
          end

          next unless node.name == 'h3'
          next if IGNORE_TYPES.include?(type)
          next if IGNORE_IDS.include?(node['id'])

          if %w(Display Durations Get\ +\ Set i18n Manipulate Query Utilities).include?(type) ||
             %w(/parsing/is-valid/
                /parsing/parse-zone/
                /parsing/unix-timestamp/
                /parsing/utc/
                /parsing/creation-data/
                /customization/relative-time-threshold/
                /customization/relative-time-rounding/
                /customization/calendar-format/
                /customization/now/
              ).include?(node['id'])
            name = node.next_element.content[/moment(?:\(.*?\))?\.(?:duration\(\)\.)?\w+/]
            name.sub! %r{\(.*?\)\.}, '#'
            name << '()'
          elsif type == 'Customize'
            name = node.next_element.content[/moment.locale\(.+?\{\s+(\w+)/, 1]
            name = node.content.strip unless name
            name.prepend 'Locale#'
          else
            name = node.content.strip
            name.prepend 'Parse: ' if type == 'Parse'
          end
          name.remove! %r{\s[\d\.]+[\s\+]*\z} # remove version number
          name.remove! %r{\s\(.+\)\z}  # remove parenthesis
          entries << [name, node['id'], type]
        end

        entries
      end
    end
  end
end
