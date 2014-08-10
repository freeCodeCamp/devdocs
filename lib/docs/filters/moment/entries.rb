module Docs
  class Moment
    class EntriesFilter < Docs::EntriesFilter
      IGNORE_IDS = %w(
        i18n-loading-into-nodejs
        i18n-loading-into-browser
        i18n-adding-locale
        i18n-getting-locale)

      def additional_entries
        entries = []
        type = nil

        css('[id]').each do |node|
          if node.name == 'h2'
            type = node.content
            next
          end

          next unless node.name == 'h3'
          next if IGNORE_IDS.include?(node['id'])

          if node['id'] == 'utilities-invalid' # bug fix
            name = 'moment.invalid()'
          elsif %w(Display Durations Get\ +\ Set i18n Manipulate Query Utilities).include?(type) ||
                %w(parsing-is-valid parsing-parse-zone parsing-unix-timestamp parsing-utc customization-relative-time-threshold).include?(node['id'])
            name = node.next_element.content[/moment(?:\(.*?\))?\.(?:duration\(\)\.)?\w+/]
            name.sub! %r{\(.*?\)\.}, '#'
            name << '()'
          elsif type == 'Customize'
            name = node.next_element.content[/moment.locale\(.+?\{\s+(\w+)/, 1]
            name.prepend 'Locale#'
          else
            name = node.content.strip
            name.remove! %r{\s[\d\.]+[\s\+]*\z} # remove version number
            name.remove! %r{\s\(.+\)\z}  # remove parenthesis
            name.prepend 'Parse: ' if type == 'Parse'
          end

          entries << [name, node['id'], type]
        end

        entries
      end
    end
  end
end
