module Docs
  class Elixir
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.split(' ').first.strip
      end

      def get_type
        case at_css('h1 small').try(:content)
        when 'exception'
          'Exceptions'
        when 'protocol'
          'Protocols'
        else
          name.split('.').first
        end
      end

      def additional_entries
        return [] if type == 'Exceptions'

        css('.detail-header .signature').map do |node|
          id = node.parent['id']
          name = node.content.strip
          name.remove! %r{\(.*\)}
          name.remove! 'left '
          name.remove! ' right'
          name.sub! 'sigil_', '~'

          unless node.parent['class'].end_with?('macro') || self.name.start_with?('Kernel')
            name.prepend "#{self.name}."
            name << " (#{id.split('/').last})"
          end

          [name, id]
        end
      end
    end
  end
end
